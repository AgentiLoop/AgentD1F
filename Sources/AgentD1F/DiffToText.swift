//
//  DiffToText.swift
//  MultiLineDiff
//
//  Created by Todd Bruss on 5/25/25.
//

import Foundation
import AgentAudit

// MARK: - Centralized Emoji Symbol Definitions
public struct DiffSymbols {
    public static let retain = "📎"
    public static let delete = "❌"
    public static let insert = "✅"
    public static let unknown = "❓"
}

struct DiffLine: Identifiable {
    let id = UUID()
    let content: String
    let type: DiffLineType
}

enum DiffLineType {
    case retain
    case insert
    case delete
    case unchanged
}

enum DiffOperationToText {
    case retain
    case delete
    case insert
    case unknown
    
    var rawValue: String {
        switch self {
        case .retain: return DiffSymbols.retain
        case .delete: return DiffSymbols.delete
        case .insert: return DiffSymbols.insert
        case .unknown: return DiffSymbols.unknown
        }
    }
    
    init(from operation: String) {
        guard let firstChar = operation.first?.description else {
            self = .unknown
            return
        }
        
        switch firstChar {
        case DiffSymbols.retain:
            self = .retain
        case DiffSymbols.delete:
            self = .delete
        case DiffSymbols.insert:
            self = .insert
        default:
            self = .unknown
        }
    }
    
}

struct DiffOperationToTextModel {
    let operation: String
    let index: Int
    
    var style: DiffOperationToText {
        DiffOperationToText(from: operation)
    }
    
    var symbol: String {
        style.rawValue
    }
    
    var description: String {
        String(operation.dropFirst())
    }
}

// Alias for compatibility with SwiftUI code
typealias DiffOperationModel = DiffOperationToTextModel

class DiffProcessor {
    static func generateDetailDiffLines(from diffResult: DiffResult, sourceText: String) -> [String] {
        var result: [String] = []
        var sourceIndex = 0
        
        for operation in diffResult.operations {
            switch operation {
            case .retain(let count):
                let retainText = StringHelper.extractSubstring(
                    from: sourceText,
                    start: sourceIndex,
                    length: count
                )
                // Use prefixLines to format each line with retain symbol
                let prefixLines = StringHelper.prefixLines(retainText, with: DiffSymbols.retain)
                // Split into individual lines and add to result
                prefixLines.enumerateLines { line, _ in
                    if !line.isEmpty {
                        result.append(line)
                    }
                }
                sourceIndex += count
                
            case .delete(let count):
                let deleteText = StringHelper.extractSubstring(
                    from: sourceText,
                    start: sourceIndex,
                    length: count
                )
                // Use prefixLines to format each line with delete symbol
                let prefixLines = StringHelper.prefixLines(deleteText, with: DiffSymbols.delete)
                // Split into individual lines and add to result
                prefixLines.enumerateLines { line, _ in
                    if !line.isEmpty {
                        result.append(line)
                    }
                }
                sourceIndex += count
                
            case .insert(let insertText):
                // Use prefixLines to format each line with insert symbol
                let prefixLines = StringHelper.prefixLines(insertText, with: DiffSymbols.insert)
                // Split into individual lines and add to result
                prefixLines.enumerateLines { line, _ in
                    if !line.isEmpty {
                        result.append(line)
                    }
                }
            }
        }
        
        return result
    }
    
    private static func processOperation(type: String, text: String,
                                         detailLines: inout [String],
                                         debugText: inout String) {
        let prefixLines = StringHelper.prefixLines(text, with: type)
        detailLines.append("\(type)\(text)")
        debugText += prefixLines
    }
}

struct StringHelper {
    static func extractSubstring(from text: String, start: Int, length: Int) -> String {
        // Clamp to bounds — a malformed diff (retain/delete count past EOF) must
        // not trap on String.index(_:offsetBy:).
        guard start >= 0, length > 0,
              let startIndex = text.index(text.startIndex, offsetBy: start, limitedBy: text.endIndex) else {
            return ""
        }
        let endIndex = text.index(startIndex, offsetBy: length, limitedBy: text.endIndex) ?? text.endIndex
        return String(text[startIndex..<endIndex])
    }
    
    static func prefixLines(_ text: String, with prefix: String) -> String {
        var result = ""
        text.enumerateLines { line, _ in
            result.append("\(prefix)\(line)\n")
        }
        return result
    }
}

// MARK: - Terminal and ASCII Diff Representations

/// ANSI color codes for terminal output
enum ANSIColor: String {
    case reset = "\u{001B}[0m"
    case red = "\u{001B}[31m"
    case green = "\u{001B}[32m"
    case blue = "\u{001B}[34m"
    case yellow = "\u{001B}[33m"
    case gray = "\u{001B}[90m"
    case bold = "\u{001B}[1m"
    
    // Background colors
    case redBg = "\u{001B}[41m"
    case greenBg = "\u{001B}[42m"
    case blueBg = "\u{001B}[44m"
    case grayBg = "\u{001B}[100m"
}

/// Terminal diff formatter for colored output
public struct TerminalDiffFormatter {
    
    /// Generate ASCII text diff representation (no colors)
    public static func generateASCIIDiff(from diffResult: DiffResult, sourceText: String) -> String {
        let formattedLines = DiffProcessor.generateDetailDiffLines(from: diffResult, sourceText: sourceText)
        return formattedLines.joined(separator: "\n")
    }
    
    /// Generate colored terminal diff representation
    public static func generateColoredTerminalDiff(from diffResult: DiffResult, sourceText: String) -> String {
        let formattedLines = DiffProcessor.generateDetailDiffLines(from: diffResult, sourceText: sourceText)
        var coloredOutput = ""
        
        for line in formattedLines {
            guard let firstChar = line.first else { continue }
            let operation = DiffOperationToText(from: String(firstChar))
            let color = getTerminalColor(for: operation)
            
            // Format: [COLOR][LINE][RESET]
            coloredOutput += "\(color)\(line)\(ANSIColor.reset.rawValue)\n"
        }
        
        return coloredOutput
    }
    
    /// Generate colored terminal diff with background highlighting
    public static func generateHighlightedTerminalDiff(from diffResult: DiffResult, sourceText: String) -> String {
        let formattedLines = DiffProcessor.generateDetailDiffLines(from: diffResult, sourceText: sourceText)
        var highlightedOutput = ""
        
        for line in formattedLines {
            guard let firstChar = line.first else { continue }
            let operation = DiffOperationToText(from: String(firstChar))
            let (textColor, bgColor) = getTerminalHighlightColors(for: operation)
            
            // Format: [BG_COLOR][TEXT_COLOR][LINE][RESET]
            highlightedOutput += "\(bgColor)\(textColor)\(line)\(ANSIColor.reset.rawValue)\n"
        }
        
        return highlightedOutput
    }
    
    /// Generate compact diff summary
    public static func generateCompactDiff(from diffResult: DiffResult) -> String {
        var summary = ""
        var operationCount = [String: Int]()
        
        for operation in diffResult.operations {
            switch operation {
            case .retain(let count):
                operationCount["retained"] = (operationCount["retained"] ?? 0) + count
            case .delete(let count):
                operationCount["deleted"] = (operationCount["deleted"] ?? 0) + count
            case .insert(let text):
                operationCount["inserted"] = (operationCount["inserted"] ?? 0) + text.count
            }
        }
        
        summary += "📊 Diff Summary:\n"
        if let retained = operationCount["retained"] {
            summary += "  \(ANSIColor.blue.rawValue)= \(retained) characters retained\(ANSIColor.reset.rawValue)\n"
        }
        if let deleted = operationCount["deleted"] {
            summary += "  \(ANSIColor.red.rawValue)- \(deleted) characters deleted\(ANSIColor.reset.rawValue)\n"
        }
        if let inserted = operationCount["inserted"] {
            summary += "  \(ANSIColor.green.rawValue)+ \(inserted) characters inserted\(ANSIColor.reset.rawValue)\n"
        }
        
        return summary
    }
    
    // MARK: - Private Helper Methods
    
    private static func getTerminalColor(for operation: DiffOperationToText) -> String {
        switch operation {
        case .retain:
            return ANSIColor.blue.rawValue
        case .delete:
            return ANSIColor.red.rawValue
        case .insert:
            return ANSIColor.green.rawValue
        case .unknown:
            return ANSIColor.gray.rawValue
        }
    }
    
    private static func getTerminalHighlightColors(for operation: DiffOperationToText) -> (text: String, background: String) {
        switch operation {
        case .retain:
            return (ANSIColor.blue.rawValue, ANSIColor.grayBg.rawValue)
        case .delete:
            return (ANSIColor.red.rawValue, ANSIColor.redBg.rawValue)
        case .insert:
            return (ANSIColor.green.rawValue, ANSIColor.greenBg.rawValue)
        case .unknown:
            return (ANSIColor.gray.rawValue, ANSIColor.grayBg.rawValue)
        }
    }
}

/// Convenience extension for MultiLineDiff to generate terminal output
extension MultiLineDiff {
    
    /// Generate ASCII diff representation
    public static func generateASCIIDiff(
        source: String,
        destination: String,
        algorithm: DiffAlgorithm = .megatron
    ) -> String {
        let diffResult = createDiff(
            source: source,
            destination: destination,
            algorithm: algorithm,
            includeMetadata: false
        )
        return TerminalDiffFormatter.generateASCIIDiff(from: diffResult, sourceText: source)
    }
    
    /// Generate colored terminal diff representation
    public static func generateColoredTerminalDiff(
        source: String,
        destination: String,
        algorithm: DiffAlgorithm = .megatron
    ) -> String {
        let diffResult = createDiff(
            source: source,
            destination: destination,
            algorithm: algorithm,
            includeMetadata: false
        )
        return TerminalDiffFormatter.generateColoredTerminalDiff(from: diffResult, sourceText: source)
    }
    
    /// Generate highlighted terminal diff representation
    public static func generateHighlightedTerminalDiff(
        source: String,
        destination: String,
        algorithm: DiffAlgorithm = .megatron
    ) -> String {
        let diffResult = createDiff(
            source: source,
            destination: destination,
            algorithm: algorithm,
            includeMetadata: false
        )
        return TerminalDiffFormatter.generateHighlightedTerminalDiff(from: diffResult, sourceText: source)
    }
    
    /// Generate compact diff summary
    public static func generateDiffSummary(
        source: String,
        destination: String,
        algorithm: DiffAlgorithm = .megatron
    ) -> String {
        let diffResult = createDiff(
            source: source,
            destination: destination,
            algorithm: algorithm,
            includeMetadata: false
        )
        return TerminalDiffFormatter.generateCompactDiff(from: diffResult)
    }
}

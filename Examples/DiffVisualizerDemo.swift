// SwiftUI demo for AgentD1F — NOT part of the library target.
// Drop this file into an app target that depends on AgentD1F to try it.
import SwiftUI
@testable import AgentD1F  // DiffOperationToText / DiffOperationToTextModel are internal

extension DiffOperationToText {
    var textColor: Color {
        switch self {
        case .retain: return .blue
        case .delete: return .red
        case .insert: return .green
        case .unknown: return .primary
        }
    }
    
    var numberBackground: Color {
        switch self {
        case .retain: return .blue
        case .delete: return .red
        case .insert: return .green
        case .unknown: return .gray
        }
    }
    
    var background: Color {
        switch self {
        case .retain: return Color(red: 0.1, green: 0.1, blue: 0.3)
        case .delete: return Color(red: 0.3, green: 0.1, blue: 0.1)
        case .insert: return Color(red: 0.1, green: 0.3, blue: 0.1)
        case .unknown: return Color.gray.opacity(0.1)
        }
    }
}

extension DiffOperationToTextModel {    
    var textColor: Color {
        style.textColor
    }
    
    var numberBackground: Color {
        style.numberBackground
    }
    
    var background: Color {
        style.background
    }
}

class DiffViewModel: ObservableObject {
    @Published var sourceText: String = """
    class UserManager {
        private var users: [String: User] = [:]
        
        func addUser(name: String, email: String) -> Bool {
            guard !name.isEmpty && !email.isEmpty else {
                return false
            }
            
            let user = User(name: name, email: email)
            users[email] = user
            return true
        }
        
        func getUser(by email: String) -> User? {
            return users[email]
        }
        
        func removeUser(email: String) {
            users.removeValue(forKey: email)
        }
        
        func getAllUsers() -> [User] {
            return Array(users.values)
        }
    }
    
    struct User {
        let name: String
        let email: String
    }
    """
    
    @Published var destinationText: String = """
    class UserManager {
        private var users: [String: User] = [:]
        private var userCount: Int = 0
        
        func addUser(name: String, email: String, age: Int = 0) -> Result<User, UserError> {
            guard !name.isEmpty && !email.isEmpty else {
                return .failure(.invalidInput)
            }
            
            guard !users.keys.contains(email) else {
                return .failure(.userAlreadyExists)
            }
            
            let user = User(id: UUID(), name: name, email: email, age: age)
            users[email] = user
            userCount += 1
            return .success(user)
        }
        
        func getUser(by email: String) -> User? {
            return users[email]
        }
        
        func removeUser(email: String) -> Bool {
            guard users[email] != nil else { return false }
            users.removeValue(forKey: email)
            userCount -= 1
            return true
        }
        
        func getAllUsers() -> [User] {
            return Array(users.values).sorted { $0.name < $1.name }
        }
        
        var count: Int {
            return userCount
        }
    }
    
    struct User {
        let id: UUID
        let name: String
        let email: String
        let age: Int
    }
    
    enum UserError: Error {
        case invalidInput
        case userAlreadyExists
    }
    """
    
    @Published var detailDiffLines: [String] = []
    @Published var diffResult: DiffResult?
    
    func generateDiff() {
        do {
            // Ensure both texts end with newline
            var normalizedSource = sourceText
            var normalizedDestination = destinationText
            
            if !normalizedSource.hasSuffix("\n") {
                normalizedSource += "\n"
            }
            
            if !normalizedDestination.hasSuffix("\n") {
                normalizedDestination += "\n"
            }
            
            let diffResult = MultiLineDiff.createDiff(
                source: normalizedSource, 
                destination: normalizedDestination,
                algorithm: .megatron,
                includeMetadata: true
            )
            
            detailDiffLines = DiffProcessor.generateDetailDiffLines(
                from: diffResult, 
                sourceText: normalizedSource
            )
            
            let base64Diff = try MultiLineDiff.createBase64Diff(
                source: normalizedSource, 
                destination: normalizedDestination,
                includeMetadata: true
            )
            print("Base64 Encoded Diff: \(base64Diff)")
            
            let reconstructedText = try MultiLineDiff.applyDiff(
                to: normalizedSource, 
                diff: diffResult
            )
            print("Reconstructed Text Matches: \(reconstructedText == normalizedDestination)")
        } catch {
            print("Diff generation error: \(error)")
            detailDiffLines = ["Error generating diff"]
        }
    }
}

struct DiffOperationView: View {
    let model: DiffOperationModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(model.symbol)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(model.numberBackground)
                .clipShape(Circle())
                .padding(4)
            
            HStack(alignment: .center, spacing: 8) {
                Text(model.description)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(model.textColor)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .offset(y: 8)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .background(model.background)
    }
}

@available(macOS 11.0, iOS 14.0, *)
struct DiffVisualizationView: View {
    @StateObject private var viewModel = DiffViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 40
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Multi-Line Diff Visualizer")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)
                
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Original")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.medium)
                                .frame(width: availableWidth / 2, alignment: .leading)

                            Text("Modified")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.medium)
                                .frame(width: availableWidth / 2, alignment: .leading)
                                .padding(.trailing, 12)
                        }
                        
                        HStack {
                            TextEditor(text: $viewModel.sourceText)
                                .font(.system(.body, design: .monospaced))
                                .padding(8)
                                .background(Color(white: 0.12))
                                .cornerRadius(8)
                                .padding(.trailing, 12)
                                .disableAutocorrection(true)
                            
                            TextEditor(text: $viewModel.destinationText)
                                .font(.system(.body, design: .monospaced))
                                .padding(8)
                                .background(Color(white: 0.12))
                                .cornerRadius(8)
                                .disableAutocorrection(true)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Diff Operations")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.medium)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(Array(viewModel.detailDiffLines.enumerated()), id: \.offset) { index, line in
                                    DiffOperationView(
                                        model: DiffOperationModel(
                                            operation: line, 
                                            index: index + 1
                                        )
                                    )
                                }
                            }
                            .background(Color(white: 0.12))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: viewModel.generateDiff) {
                    Text("Generate Diff")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .frame(minHeight: 12)
                }
            }
            .padding(20)
        }
    }
}

@available(macOS 11.0, iOS 14.0, *)
struct ContentView: View {
    var body: some View {
        DiffVisualizationView()
    }
}

@available(macOS 11.0, iOS 14.0, *)
#Preview {
    ContentView()
}


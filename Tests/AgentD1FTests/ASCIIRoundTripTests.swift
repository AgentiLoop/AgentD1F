import Testing
@testable import AgentD1F

@Suite("ASCII round-trip")
struct ASCIIRoundTripTests {
    @Test("generateASCIIDiff output (emoji markers) parses and re-applies to the destination")
    func emojiMarkersRoundTrip() throws {
        let source = "let a = 1\nlet b = 2\nlet c = 3\n"
        let destination = "let a = 1\nlet b = 20\nlet c = 3\nlet d = 4\n"
        let ascii = MultiLineDiff.generateASCIIDiff(source: source, destination: destination)
        #expect(ascii.contains(DiffSymbols.insert))
        let applied = try MultiLineDiff.applyASCIIDiff(to: source, asciiDiff: ascii)
        // ASCII diffs are line-based: the trailing newline is not part of the contract.
        #expect(applied == String(destination.dropLast()))
    }

    @Test("plain =/-/+ prefixes still parse")
    func plainPrefixes() throws {
        let ascii = "=let a = 1\n-let b = 2\n+let b = 20\n"
        let applied = try MultiLineDiff.applyASCIIDiff(to: "let a = 1\nlet b = 2\n", asciiDiff: ascii)
        #expect(applied == "let a = 1\nlet b = 20")
    }

    @Test("fallback hash is deterministic")
    func stableHash() {
        #expect(MultiLineDiff.stableHash("hello") == MultiLineDiff.stableHash("hello"))
        #expect(MultiLineDiff.stableHash("hello") != MultiLineDiff.stableHash("hellp"))
        #expect(MultiLineDiff.stableHash("hello") == 0xa430d84680aabd0b)
    }
}

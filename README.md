# AgentD1F

Multi-line diff engine with Flash, Megatron, and Optimus algorithms for Swift.

## ✅ Interactive Demo

**🚀 Try the Live Demo**: [d1f.ai](https://d1f.ai)

Experience the power of MultiLineDiff algorithms in real-time with our interactive JavaScript implementation:

- **⚡ Flash Algorithm**: Lightning-fast prefix/suffix detection (14.5ms)
- **🤖 Optimus Algorithm**: Line-aware CollectionDifference processing (43.7ms)  
- **🧠 Megatron Algorithm**: Semantic analysis with balanced performance (47.8ms)
- **🌟 Starscream Algorithm**: Swift-native line processing (45.1ms)
- **🔍 Zoom Algorithm**: Simple character-based diffing (23.9ms)

**Real-time Performance Monitoring**: Watch actual algorithm execution times as you type!

## 📦 Package Information

**Repository**: [AgentiLoop/AgentD1F](https://github.com/AgentiLoop/AgentD1F.git)  
**Website**: [d1f.ai](https://d1f.ai) - Interactive Demo & Documentation  
**License**: MIT  
**Language**: Swift 100%  
**Latest Release**: v1.0.11  
**Creator**: AgentiLoop © xcf.ai

---

## 🚀 Installation Methods

### Method 1: Swift Package Manager (Recommended)

#### Via Xcode
1. Open your Xcode project
2. Go to **File** → **Add Package Dependencies**
3. Enter the repository URL:
   ```
   https://github.com/AgentiLoop/AgentD1F.git
   ```
4. Select version `1.0.12` or **Up to Next Major Version**
5. Click **Add Package**
6. Select **AgentD1F** target and click **Add Package**

#### Via Package.swift
Add the dependency to your `Package.swift` file:

```swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "YourProject",
    platforms: [
        .macOS(.v26)
    ],
    dependencies: [
        .package(
            url: "https://github.com/AgentiLoop/AgentD1F.git",
            from: "1.0.12"
        )
    ],
    targets: [
        .target(
            name: "YourTarget",
            dependencies: [
                .product(name: "AgentD1F", package: "AgentD1F")
            ]
        )
    ]
)
```

Then run:
```bash
swift package resolve
swift build
```

### Method 2: Local Compilation

#### Clone and Build Locally
```bash
# Clone the repository
git clone https://github.com/AgentiLoop/AgentD1F.git
cd AgentD1F

# Build the package
swift build

# Run tests to verify installation
swift test

# Build in release mode for production
swift build -c release
```

#### Integration into Local Project
```bash
# Add as a local dependency in your Package.swift
.package(path: "../path/to/AgentD1F")
```

---

## 📱Apple Platform Support

| Platform | Minimum Version |
|----------|----------------|
| **macOS** | 26+ (Swift 6.2+) |

Users are welcome to fork and port MultiLineDiff to Linux, Windows and Ubuntu!

---

## 🔧 Basic Usage

### Import the Package
```swift
import MultiLineDiff
```

### Quick Start Examples

#### 1. Basic Diff Creation
```swift
import MultiLineDiff

let source = """
func greet() {
    print("Hello")
}
"""

let destination = """
func greet() {
    print("Hello, World!")
}
"""

// Create diff using default Megatron algorithm
let diff = MultiLineDiff.createDiff(
    source: source,
    destination: destination
)

// Apply the diff
let result = try MultiLineDiff.applyDiff(to: source, diff: diff)
print(result) // Outputs the destination text
```

#### 2. Algorithm Selection
```swift
// Ultra-fast Flash algorithm (recommended for speed)
let flashDiff = MultiLineDiff.createDiff(
    source: source,
    destination: destination,
    algorithm: .flash
)

// Detailed Optimus algorithm (recommended for precision)
let optimusDiff = MultiLineDiff.createDiff(
    source: source,
    destination: destination,
    algorithm: .optimus
)

// Semantic Megatron algorithm (recommended for complex changes)
let megatronDiff = MultiLineDiff.createDiff(
    source: source,
    destination: destination,
    algorithm: .megatron
)
```

#### 3. ASCII Diff Display
```swift
// Generate AI-friendly ASCII diff
let asciiDiff = MultiLineDiff.createAndDisplayDiff(
    source: source,
    destination: destination,
    format: .ai,
    algorithm: .flash
)

print("ASCII Diff for AI:")
print(asciiDiff)

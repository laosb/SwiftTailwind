// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "SwiftTailwind",
  platforms: [.macOS(.v12)],
  products: [
    .plugin(name: "TailwindCSS", targets: ["TailwindCSS"]),
    .executable(name: "TailwindCSSCLIArtifactBundler", targets: ["TailwindCSSCLIArtifactBundler"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.7.0"),
    .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0"..<"5.0.0"),
  ],
  targets: [
    .executableTarget(
      name: "TailwindCSSCLIArtifactBundler",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Crypto", package: "swift-crypto"),
      ]
    ),
    .plugin(name: "TailwindCSS", capability: .buildTool(), dependencies: ["TailwindCSSCLI"]),
    .binaryTarget(
      name: "TailwindCSSCLI",
      url:
        "https://github.com/laosb/SwiftTailwind/releases/download/1.1.0-test.4+tw.4.1.14/tailwindcss.artifactbundleindex",
      checksum: "ec4df49e361db5fc3159c431e5661af2e1b22d8575c64ce0482a8e84cfd93d04"
    ),
    .target(
      name: "SwiftTailwindExample",
      resources: [.copy("Views/Test.html")],
      plugins: ["TailwindCSS"]
    ),
    .testTarget(name: "SwiftTailwindTests", dependencies: ["SwiftTailwindExample"]),
  ]
)

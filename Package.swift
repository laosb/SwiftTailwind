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
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
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
        "https://github.com/laosb/SwiftTailwind/releases/download/1.1.0.test.0%2Btw.4.1.14/tailwindcss.artifactbundleindex",
      checksum: "cdc10d3dbd0ad593d68df5564f22c5fc6ffe57facb30a8665d0be073e7fb9c66"
    ),
    .target(
      name: "SwiftTailwindExample",
      resources: [.copy("Views/Test.html")],
      plugins: ["TailwindCSS"]
    ),
    .testTarget(name: "SwiftTailwindTests", dependencies: ["SwiftTailwindExample"]),
  ]
)

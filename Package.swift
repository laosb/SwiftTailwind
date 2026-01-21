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
        "https://github.com/laosb/SwiftTailwind/releases/download/TailwindCSSCLI-v4.1.18-e41dde7884391c83e50815a25dc0db70061b2dfdc9ed9026e31689594a2305af/tailwindcss.artifactbundleindex",
      checksum: "e41dde7884391c83e50815a25dc0db70061b2dfdc9ed9026e31689594a2305af"
    ),
    .target(
      name: "SwiftTailwindExample",
      resources: [.copy("Views/Test.html")],
      plugins: ["TailwindCSS"]
    ),
    .testTarget(name: "SwiftTailwindTests", dependencies: ["SwiftTailwindExample"]),
  ]
)

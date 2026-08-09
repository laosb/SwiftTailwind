// swift-tools-version: 6.1

import PackageDescription

let tailwindCSSCLITarget: Target =
  if let artifactPath = Context.environment["SWIFTTAILWIND_CLI_ARTIFACT_PATH"],
    !artifactPath.isEmpty
  {
    .binaryTarget(name: "TailwindCSSCLI", path: artifactPath)
  } else if let artifactURL = Context.environment["SWIFTTAILWIND_CLI_ARTIFACT_URL"],
    let artifactChecksum = Context.environment["SWIFTTAILWIND_CLI_ARTIFACT_CHECKSUM"],
    !artifactURL.isEmpty,
    !artifactChecksum.isEmpty
  {
    .binaryTarget(name: "TailwindCSSCLI", url: artifactURL, checksum: artifactChecksum)
  } else {
    .binaryTarget(
      name: "TailwindCSSCLI",
      url: "https://github.com/laosb/SwiftTailwind/releases/download/TailwindCSSCLI-v4.3.3-00553dd33b62f0dc34b48d2105da59800a1c209dd0db89bd213f6bcf26b276f2/tailwindcss.artifactbundleindex",
      checksum: "00553dd33b62f0dc34b48d2105da59800a1c209dd0db89bd213f6bcf26b276f2"
    )
  }

let package = Package(
  name: "SwiftTailwind",
  platforms: [.macOS(.v13)],
  products: [
    .plugin(name: "TailwindCSS", targets: ["TailwindCSS"]),
    .executable(name: "TailwindCSSCLIArtifactBundler", targets: ["TailwindCSSCLIArtifactBundler"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.7.0"),
    .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0"..<"5.0.0"),
    .package(
      url: "https://github.com/swiftlang/swift-subprocess.git",
      .upToNextMinor(from: "0.4.0"),
      traits: []
    ),
  ],
  targets: [
    .executableTarget(
      name: "TailwindCSSCLIArtifactBundler",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Crypto", package: "swift-crypto"),
        .product(name: "Subprocess", package: "swift-subprocess"),
      ]
    ),
    .plugin(name: "TailwindCSS", capability: .buildTool(), dependencies: ["TailwindCSSCLI"]),
    tailwindCSSCLITarget,
    .target(
      name: "SwiftTailwindExample",
      resources: [.copy("Views/Test.html")],
      plugins: ["TailwindCSS"]
    ),
    .testTarget(name: "SwiftTailwindTests", dependencies: ["SwiftTailwindExample"]),
  ]
)

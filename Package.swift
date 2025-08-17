// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "SwiftTailwind",
  platforms: [.macOS(.v12)],
  products: [
    .plugin(name: "TailwindCSS", targets: ["TailwindCSS"])
  ],
  targets: [
    .plugin(name: "TailwindCSS", capability: .buildTool(), dependencies: ["TailwindCSSCLI"]),
    .binaryTarget(
      name: "TailwindCSSCLI",
      url:
        "https://github.com/laosb/SwiftTailwind/releases/download/4.1.12-test-manual.1/tailwindcss.artifactbundle.zip",
      checksum: "bfa96ef1d4d1b665bb40c89ec906044c9532b3cabf866fbe2bd3e5a95bf40bea"
    ),
    .target(
      name: "SwiftTailwindExample",
      resources: [.copy("Folder")],
      plugins: ["TailwindCSS"]
    ),
    .testTarget(name: "SwiftTailwindTests", dependencies: ["SwiftTailwindExample"]),
  ]
)

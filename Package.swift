// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "SwiftTailwind",
  platforms: [.macOS(.v12)],
  products: [
    .plugin(name: "TailwindCSS", targets: ["TailwindCSS"])
  ],
  targets: [
    .plugin(name: "TailwindCSS", capability: .buildTool())
  ]
)

import ArgumentParser
import Foundation

@main
struct TailwindCSSCLIArtifactBundler: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "TailwindCSSCLIArtifactBundler",
    abstract: "Build TailwindCSS CLI artifact bundles for Swift Package Manager",
    version: "1.0.0"
  )

  @Option(name: .shortAndLong, help: "TailwindCSS version to build (e.g., v4.1.14)")
  var version: String

  @Option(name: .shortAndLong, help: "Working directory for temporary files")
  var workDir: String = "/tmp/tailwindcss-bundles"

  @Option(name: .shortAndLong, help: "Output directory for the artifact bundle index")
  var outputDir: String = "."

  func run() throws {
    print("Building artifact bundles for TailwindCSS version: \(version)")

    let bundler = ArtifactBundleBuilder(
      version: version,
      workDir: workDir,
      outputDir: outputDir
    )

    try bundler.buildArtifactBundles()
  }
}

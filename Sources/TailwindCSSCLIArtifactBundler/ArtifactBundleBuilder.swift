import Crypto
import Foundation

class ArtifactBundleBuilder {
  private let version: String
  private let workDir: String
  private let outputDir: String
  private let fileManager = FileManager.default

  private let binaryConfigurations: [BinaryConfiguration] = [
    BinaryConfiguration(binaryName: "tailwindcss-linux-x64", triple: "x86_64-unknown-linux-gnu"),
    BinaryConfiguration(binaryName: "tailwindcss-macos-x64", triple: "x86_64-apple-darwin"),
    BinaryConfiguration(binaryName: "tailwindcss-macos-arm64", triple: "aarch64-apple-darwin"),
  ]

  init(version: String, workDir: String, outputDir: String) {
    self.version = version
    self.workDir = workDir
    self.outputDir = outputDir
  }

  func buildArtifactBundles() throws {
    try setupWorkingDirectory()

    var bundleInfos: [BundleInfo] = []

    print("Creating individual bundles...")
    for config in binaryConfigurations {
      let bundleInfo = try createBundle(for: config)
      bundleInfos.append(bundleInfo)
    }

    try generateArtifactBundleIndex(bundleInfos: bundleInfos)

    print("=== BUILD COMPLETE ===")
    print("All bundles created successfully:")
    print("")
    print("Generated artifact bundle index: \(outputDir)/tailwindcss.artifactbundleindex")
    print("")

    let indexChecksum = try computeChecksum(
      filePath: "\(outputDir)/tailwindcss.artifactbundleindex", usingSHA256Directly: true)
    print("Index checksum: \(indexChecksum)")
    print("")

    for bundleInfo in bundleInfos {
      print("Bundle: \(bundleInfo.fileName)")
      print("  Checksum: \(bundleInfo.checksum)")
      print("  Triple: \(bundleInfo.triple)")
      print("")
    }
  }

  private func setupWorkingDirectory() throws {
    print("Creating working directory: \(workDir)")

    if fileManager.fileExists(atPath: workDir) {
      try fileManager.removeItem(atPath: workDir)
    }

    try fileManager.createDirectory(atPath: workDir, withIntermediateDirectories: true)
  }

  private func createBundle(for config: BinaryConfiguration) throws -> BundleInfo {
    let bundleDirName = "tailwindcss-\(version)-\(config.triple).artifactbundle"
    let bundleDir = "\(workDir)/\(bundleDirName)"
    let binaryPath = "bin/tailwindcss"

    print("Creating bundle for \(config.triple)...")

    // Create bundle directory structure
    let binDir = "\(bundleDir)/bin"
    try fileManager.createDirectory(atPath: binDir, withIntermediateDirectories: true)

    // Download binary
    print("  Downloading \(config.binaryName)...")
    let binaryURL =
      "https://github.com/tailwindlabs/tailwindcss/releases/download/\(version)/\(config.binaryName)"
    let binaryDestination = "\(bundleDir)/\(binaryPath)"

    try downloadFile(from: binaryURL, to: binaryDestination)
    try makeExecutable(path: binaryDestination)
    print("  ✓ Downloaded and made executable: \(binaryDestination)")

    // Create info.json
    print("  Creating info.json...")
    try createInfoJSON(bundleDir: bundleDir, binaryPath: binaryPath, triple: config.triple)
    print(
      "  ✓ Created info.json with version \(version), path \(binaryPath), triple \(config.triple)")

    // Create ZIP file
    let zipFileName = "\(bundleDirName).zip"
    let zipPath = "\(outputDir)/\(zipFileName)"
    print("  Creating ZIP file: \(zipPath)")

    try createZipFile(bundleDir: bundleDir, zipPath: zipPath)

    // Compute checksum
    print("  Computing checksum...")
    let checksum = try computeChecksum(filePath: zipPath)

    print("  ✓ Bundle created: \(zipPath)")
    print("  ✓ Checksum: \(checksum)")
    print("")

    return BundleInfo(fileName: zipFileName, checksum: checksum, triple: config.triple)
  }

  private func downloadFile(from urlString: String, to destination: String) throws {
    guard let url = URL(string: urlString) else {
      throw ArtifactBundleError.invalidURL(urlString)
    }

    let data = try Data(contentsOf: url)
    try data.write(to: URL(fileURLWithPath: destination))
  }

  private func makeExecutable(path: String) throws {
    let attributes = [FileAttributeKey.posixPermissions: 0o755]
    try fileManager.setAttributes(attributes, ofItemAtPath: path)
  }

  private func createInfoJSON(bundleDir: String, binaryPath: String, triple: String) throws {
    let artifact = Artifact(
      version: version,
      type: "executable",
      variants: [
        ArtifactVariant(path: binaryPath, supportedTriples: [triple])
      ]
    )

    let info = ArtifactBundleInfo(
      schemaVersion: "1.0",
      artifacts: ["tailwindcss": artifact]
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    let jsonData = try encoder.encode(info)
    let infoPath = "\(bundleDir)/info.json"
    try jsonData.write(to: URL(fileURLWithPath: infoPath))
  }

  private func createZipFile(bundleDir: String, zipPath: String) throws {
    // Remove existing ZIP file if it exists
    if fileManager.fileExists(atPath: zipPath) {
      try fileManager.removeItem(atPath: zipPath)
    }

    let bundleDirURL = URL(fileURLWithPath: bundleDir)
    let workDirURL = bundleDirURL.deletingLastPathComponent()
    let bundleName = bundleDirURL.lastPathComponent

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
    process.arguments = ["-r", zipPath, bundleName]
    process.currentDirectoryURL = workDirURL

    try process.run()
    process.waitUntilExit()

    guard process.terminationStatus == 0 else {
      throw ArtifactBundleError.zipCreationFailed
    }
  }

  /// Computes the SHA256 checksum of a file.
  ///
  /// If `usingSHA256Directly` is true, it uses Swift Crypto's SHA256 implementation.
  /// This is to workaround https://github.com/swiftlang/swift-package-manager/issues/9219.
  private func computeChecksum(
    filePath: String,
    usingSHA256Directly: Bool = false
  ) throws -> String {
    if usingSHA256Directly {
      // Use swift-crypto's SHA256 implementation
      let fileURL = URL(fileURLWithPath: filePath)
      let data = try Data(contentsOf: fileURL)
      let hash = SHA256.hash(data: data)
      return hash.compactMap { String(format: "%02x", $0) }.joined()
    } else {
      // Use swift package compute-checksum command
      let process = Process()
      process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
      process.arguments = ["package", "compute-checksum", filePath]

      let pipe = Pipe()
      process.standardOutput = pipe

      try process.run()
      process.waitUntilExit()

      guard process.terminationStatus == 0 else {
        throw ArtifactBundleError.checksumComputationFailed
      }

      let data = pipe.fileHandleForReading.readDataToEndOfFile()
      let output = String(data: data, encoding: .utf8)?.trimmingCharacters(
        in: .whitespacesAndNewlines)

      guard let checksum = output, !checksum.isEmpty else {
        throw ArtifactBundleError.checksumComputationFailed
      }

      return checksum
    }
  }

  private func generateArtifactBundleIndex(bundleInfos: [BundleInfo]) throws {
    print("Generating tailwindcss.artifactbundleindex...")

    // Create output directory if it doesn't exist
    if !fileManager.fileExists(atPath: outputDir) {
      try fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
    }

    let bundles = bundleInfos.map { bundleInfo in
      Bundle(
        fileName: bundleInfo.fileName,
        checksum: bundleInfo.checksum,
        supportedTriples: [bundleInfo.triple]
      )
    }

    let index = ArtifactBundleIndex(
      schemaVersion: "1.0",
      bundles: bundles
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    let jsonData = try encoder.encode(index)
    let indexPath = "\(outputDir)/tailwindcss.artifactbundleindex"
    try jsonData.write(to: URL(fileURLWithPath: indexPath))
  }
}

enum ArtifactBundleError: Error, LocalizedError {
  case invalidURL(String)
  case zipCreationFailed
  case checksumComputationFailed

  var errorDescription: String? {
    switch self {
    case .invalidURL(let url):
      return "Invalid URL: \(url)"
    case .zipCreationFailed:
      return "Failed to create ZIP file"
    case .checksumComputationFailed:
      return "Failed to compute checksum"
    }
  }
}

import Crypto
import Foundation

extension ArtifactBundleBuilder {
  /// Computes the SHA256 checksum of a file.
  ///
  /// If `usingSHA256Directly` is true, it uses Swift Crypto's SHA256 implementation.
  /// This is to workaround https://github.com/swiftlang/swift-package-manager/issues/9219.
  func computeChecksum(
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
}

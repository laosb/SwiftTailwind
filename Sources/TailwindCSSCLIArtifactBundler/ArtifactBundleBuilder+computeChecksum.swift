import Crypto

#if canImport(FoundationEssentials)
  import FoundationEssentials
#else
  import Foundation
#endif

extension ArtifactBundleBuilder {
  /// Computes the SHA256 checksum of a file.
  func computeChecksum(filePath: String) throws -> String {
    let fileURL = URL(fileURLWithPath: filePath)
    let data = try Data(contentsOf: fileURL)
    let hash = SHA256.hash(data: data)
    return hash.map { String($0, radix: 16).leftPadding(toLength: 2, withPad: "0") }.joined()
  }
}

extension String {
  fileprivate func leftPadding(toLength: Int, withPad character: Character) -> String {
    String(repeating: character, count: max(0, toLength - count)) + self
  }
}

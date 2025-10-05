import Foundation

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

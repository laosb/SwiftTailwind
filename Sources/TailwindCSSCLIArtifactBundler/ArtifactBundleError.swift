#if canImport(FoundationEssentials)
  import FoundationEssentials
#else
  import Foundation
#endif

enum ArtifactBundleError: Error, LocalizedError {
  case invalidURL(String)
  case downloadFailed(String)
  case zipCreationFailed

  var errorDescription: String? {
    switch self {
    case .invalidURL(let url):
      return "Invalid URL: \(url)"
    case .downloadFailed(let url):
      return "Failed to download: \(url)"
    case .zipCreationFailed:
      return "Failed to create ZIP file"
    }
  }
}

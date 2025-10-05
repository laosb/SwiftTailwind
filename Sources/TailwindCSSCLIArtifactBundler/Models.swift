import Foundation

// MARK: - Artifact Bundle Info Models

/// Represents the info.json file structure for an artifact bundle
struct ArtifactBundleInfo: Codable {
  let schemaVersion: String
  let artifacts: [String: Artifact]

  enum CodingKeys: String, CodingKey {
    case schemaVersion, artifacts
  }
}

struct Artifact: Codable {
  let version: String
  let type: String
  let variants: [ArtifactVariant]
}

struct ArtifactVariant: Codable {
  let path: String
  let supportedTriples: [String]
}

// MARK: - Artifact Bundle Index Models

/// Represents the .artifactbundleindex file structure
struct ArtifactBundleIndex: Codable {
  let schemaVersion: String
  let archives: [Bundle]  // The proposal says it's "bundles" but the actual implementation uses "archives"
}

struct Bundle: Codable {
  let fileName: String
  let checksum: String
  let supportedTriples: [String]
}

// MARK: - Internal Data Models

/// Configuration for a binary platform
struct BinaryConfiguration {
  let binaryName: String
  let triple: String
}

/// Information about a created bundle
struct BundleInfo {
  let fileName: String
  let checksum: String
  let triple: String
}

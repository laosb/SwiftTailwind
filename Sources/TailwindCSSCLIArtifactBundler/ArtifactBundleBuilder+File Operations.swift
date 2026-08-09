import Subprocess

#if canImport(FoundationNetworking)
  import FoundationEssentials
  import FoundationNetworking
#else
  import Foundation
#endif

extension ArtifactBundleBuilder {
  func downloadFile(from urlString: String, to destination: String) async throws {
    guard let url = URL(string: urlString) else {
      throw ArtifactBundleError.invalidURL(urlString)
    }

    let (data, response) = try await URLSession.shared.data(from: url)
    guard
      let response = response as? HTTPURLResponse,
      (200..<300).contains(response.statusCode)
    else {
      throw ArtifactBundleError.downloadFailed(urlString)
    }

    try data.write(to: URL(fileURLWithPath: destination))
  }

  func makeExecutable(path: String) throws {
    let attributes = [FileAttributeKey.posixPermissions: 0o755]
    try fileManager.setAttributes(attributes, ofItemAtPath: path)
  }

  func createZipFile(bundleDir: String, zipPath: String) async throws {
    // Remove existing ZIP file if it exists
    if fileManager.fileExists(atPath: zipPath) {
      try fileManager.removeItem(atPath: zipPath)
    }

    let bundleDirURL = URL(fileURLWithPath: bundleDir)

    let zipPathURL = URL(fileURLWithPath: zipPath).standardizedFileURL
    let result = try await run(
      .name("zip"),
      arguments: ["-r", zipPathURL.path, "."],
      workingDirectory: .init(bundleDirURL.path),
      output: .standardOutput,
      error: .standardError)

    guard result.terminationStatus.isSuccess else {
      throw ArtifactBundleError.zipCreationFailed
    }
  }

}

import Foundation

extension ArtifactBundleBuilder {
  func downloadFile(from urlString: String, to destination: String) throws {
    guard let url = URL(string: urlString) else {
      throw ArtifactBundleError.invalidURL(urlString)
    }

    let data = try Data(contentsOf: url)
    try data.write(to: URL(fileURLWithPath: destination))
  }

  func makeExecutable(path: String) throws {
    let attributes = [FileAttributeKey.posixPermissions: 0o755]
    try fileManager.setAttributes(attributes, ofItemAtPath: path)
  }

  func createZipFile(bundleDir: String, zipPath: String) throws {
    // Remove existing ZIP file if it exists
    if fileManager.fileExists(atPath: zipPath) {
      try fileManager.removeItem(atPath: zipPath)
    }

    let bundleDirURL = URL(fileURLWithPath: bundleDir)

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
    let zipPathURL = URL(fileURLWithPath: zipPath).standardizedFileURL
    process.arguments = ["-r", zipPathURL.path, "."]
    process.currentDirectoryURL = bundleDirURL

    try process.run()
    process.waitUntilExit()

    guard process.terminationStatus == 0 else {
      throw ArtifactBundleError.zipCreationFailed
    }
  }

}

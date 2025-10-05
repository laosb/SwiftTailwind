extension ArtifactBundleBuilder {
  /// Expands a list of triples into a stricter list of triples.
  ///
  /// To workaround https://github.com/swiftlang/swift-package-manager/issues/7362.
  func expandingTriple(_ triple: String) -> [String] {
    switch triple {
    case "aarch64-apple-darwin":
      [
        "aarch64-apple-darwin",
        "arm64-apple-macosx12.0",
        "arm64-apple-macosx13.0",
        "arm64-apple-macosx14.0",
        "arm64-apple-macosx15.0",
        "arm64-apple-macosx26.0",
      ]
    case "x86_64-apple-darwin":
      [
        "x86_64-apple-darwin",
        "x86_64-apple-macosx12.0",
        "x86_64-apple-macosx13.0",
        "x86_64-apple-macosx14.0",
        "x86_64-apple-macosx15.0",
        "x86_64-apple-macosx26.0",
      ]
    // TODO: Does linux need more detailed triple variants?
    default: [triple]
    }
  }
}

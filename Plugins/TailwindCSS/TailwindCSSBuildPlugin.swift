import Foundation
import PackagePlugin
import RegexBuilder

@main
struct TailwindCSSBuildPlugin: BuildToolPlugin {
  let inputCSSFilename = "Tailwind.css"
  let outputBundleName = "TailwindCSS.bundle"
  let outputCSSFilename = "tw.css"

  let importStatementRegex = Regex {
    Anchor.startOfLine
    ZeroOrMore(.whitespace)
    "@import"
    ZeroOrMore(.whitespace)
    "\"tailwindcss\""
    ZeroOrMore(.whitespace)
    "source("
    ZeroOrMore(.whitespace)
    "none"
    ZeroOrMore(.whitespace)
    ")"
    ZeroOrMore(.whitespace)
    ";"
  }.anchorsMatchLineEndings()

  let sourceDeclarationRegex = Regex {
    Anchor.startOfLine
    ZeroOrMore(.whitespace)
    "@source"
    ZeroOrMore(.whitespace)
    "\""
    Capture { OneOrMore(CharacterClass.anyOf("\"").inverted) }
    "\""
    ZeroOrMore(.whitespace)
    ";"
  }

  let sourceNotDeclarationRegex = Regex {
    Anchor.startOfLine
    ZeroOrMore(.whitespace)
    "@source"
    ZeroOrMore(.whitespace)
    "not"
  }.anchorsMatchLineEndings()

  func createBuildCommands(
    context: PluginContext,
    target: Target
  ) throws -> [Command] {
    guard let sourceFileURLs = target.sourceModule?.sourceFiles.map({ $0.url }) else {
      throw BuildError.notASourceModule
    }

    let tailwindCSSURL: URL = target.directoryURL.appending(component: "Tailwind.css")
    guard let cssContent = try? String(contentsOf: tailwindCSSURL) else {
      throw BuildError.missingTailwindCSSFile
    }
    let matches = cssContent.matches(of: importStatementRegex)
    guard !matches.isEmpty else {
      throw BuildError.missingImportStatement
    }
    if (try? sourceNotDeclarationRegex.firstMatch(in: cssContent)) != nil {
      throw BuildError.sourceNotDeclarationUnsupported
    }

    let sourcePatterns =
      cssContent
      .matches(of: sourceDeclarationRegex)
      .compactMap { String($0.output.1) }
    let sourcePatternURLs: [URL] = sourcePatterns.map { path in
      // Simplified handling: If `**` is used, we just include everything in the directory.
      // It's unlikely we will have the same glob processing logic as Tailwind CSS CLI,
      // so we may as well just expand the coverage.
      // This only affects SwiftPM change detection: Tailwind CSS CLI will handle the globbing correctly.
      let globlessPath = path.replacing(/\*\*.*/, with: "")
      return target.directoryURL
        .appending(component: globlessPath, directoryHint: .inferFromPath)
        .resolvingSymlinksInPath()
    }

    let includedSourceURLs = sourceFileURLs.filter { file in
      sourcePatternURLs.contains { file.isOrIsDescendant(of: $0) }
    }

    let tailwindCLIURL: URL = try context.tool(named: "tailwindcss").url
    let outputBundleURL = context.pluginWorkDirectoryURL
      .appending(component: outputBundleName, directoryHint: .isDirectory)
    let outputURL = outputBundleURL.appending(
      component: outputCSSFilename, directoryHint: .notDirectory)

    print("Tailwind CSS Build Plugin")
    print("Tailwind.css: \(tailwindCSSURL.path)")
    print("@source declarations: \(sourcePatterns)")
    print("All source files: \(sourceFileURLs.map(\.path))")
    print("Input files: \(includedSourceURLs.map(\.path))")
    print("Output: \(outputURL.path)")

    return [
      .buildCommand(
        displayName: "Building Tailwind CSS",
        executable: tailwindCLIURL,
        arguments: [
          "--input", tailwindCSSURL.path,
          "--output", outputURL.path,
          "--minify",
        ],
        inputFiles: [tailwindCSSURL] + includedSourceURLs,
        outputFiles: [outputBundleURL]
      )
    ]
  }
}

extension TailwindCSSBuildPlugin {
  enum BuildError: Error {
    case notASourceModule
    case missingTailwindCSSFile
    case missingImportStatement
    case sourceNotDeclarationUnsupported

    var localizedDescription: String {
      switch self {
      case .notASourceModule:
        "The target is not a source module."
      case .missingTailwindCSSFile:
        "Tailwind.css file not found in the target directory."
      case .missingImportStatement:
        "No `@import \"tailwind\"` statement found, or `source(none)` is missing."
      case .sourceNotDeclarationUnsupported:
        "`@source not` declarations are not supported. Please explicitly declare sources with `@source \"<path>\";`."
      }
    }
  }
}

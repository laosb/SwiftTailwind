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

    let sourcePaths =
      cssContent
      .matches(of: sourceDeclarationRegex)
      .compactMap { String($0.output.1) }
    let sourceURLs: [URL] = sourcePaths.map { path in
      // Simplified handling: If ** is used, we just include everything in the directory.
      let globlessPath = path.replacing(/\*\*.*/, with: "")
      return target.directoryURL
        .appending(component: globlessPath, directoryHint: .inferFromPath)
        .resolvingSymlinksInPath()
    }

    let tailwindCLIURL: URL = try context.tool(named: "tailwindcss").url
    let outputBundleURL = context.pluginWorkDirectoryURL
      .appending(component: outputBundleName, directoryHint: .isDirectory)
    let outputURL = outputBundleURL.appending(
      component: outputCSSFilename, directoryHint: .notDirectory)

    print("Tailwind CSS Build Plugin")
    print("Tailwind CSS File: \(tailwindCSSURL.path)")
    print("@source declarations: \(sourcePaths)")
    print("Source files: \(sourceURLs.map(\.path))")
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
        inputFiles: [tailwindCSSURL] + sourceURLs,
        outputFiles: [outputBundleURL]
      )
    ]
  }
}

extension TailwindCSSBuildPlugin {
  enum BuildError: Error {
    case missingTailwindCSSFile
    case missingImportStatement
    case sourceNotDeclarationUnsupported

    var localizedDescription: String {
      switch self {
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

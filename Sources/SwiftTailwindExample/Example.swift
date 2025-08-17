import Foundation

public struct Example {
  public var htmlInSwiftCode =
    """
    <html>
    <head>
      <title>Example</title>
    </head>
    <body>
      <h1 class="text-2xl">Hello, World!</h1>
      <p>This is an example of HTML in Swift code.</p>
    </body>
    </html>
    """

  public func getTestHTML() throws -> String? {
    guard let fileURL = Bundle.module.path(forResource: "Test", ofType: "html") else {
      return nil
    }

    return try String(contentsOfFile: fileURL, encoding: .utf8)
  }

  public func getGeneratedCSS() throws -> String? {
    guard
      let tailwindCSSBundleURL = Bundle.module.url(
        forResource: "TailwindCSS", withExtension: "bundle")
    else {
      return nil
    }

    let cssFileURL = tailwindCSSBundleURL.appendingPathComponent("tw.css")
    return try String(contentsOf: cssFileURL, encoding: .utf8)
  }

  public func printAll() {
    print("HTML in Swift Code:")
    print(htmlInSwiftCode)

    print()
    print("Test.html:")
    if let testHTML = try! getTestHTML() {
      print(testHTML)
    } else {
      print("Test.html not found.")
    }

    print()
    print("Output Tailwind CSS (minified):")
    if let generatedCSS = try! getGeneratedCSS() {
      print(generatedCSS)
    } else {
      print("Tailwind CSS not found.")
    }
  }
}

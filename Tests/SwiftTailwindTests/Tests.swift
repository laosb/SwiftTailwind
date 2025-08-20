import Testing

@testable import SwiftTailwindExample

@Suite("SwiftTailwindExample")
struct SwiftTailwindExampleTests {
  @Test
  func example() throws {
    let example = Example()
    let generatedCSS = try example.getGeneratedCSS()
    #expect(generatedCSS != nil)
    #expect(
      generatedCSS?.contains("text-2xl") == true,
      "Class used in Swift code is generated."
    )
    #expect(
      generatedCSS?.contains("text-\\[\\#f05138\\]") == true,
      "Arbitary value class used in Test.html is generated."
    )
    #expect(
      generatedCSS?.contains("bg-red-100") == true,
      "Arbitary value class used in Folder/Template.swift is generated."
    )
    #expect(
      generatedCSS?.contains("text-sm") == false,
      "Class used in other non-included Swift code is not generated."
    )
    #expect(
      generatedCSS?.contains("bg-blue-500") == false,
      "Class not used is not generated."
    )
  }
}

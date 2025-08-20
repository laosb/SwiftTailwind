import Foundation

extension URL {
  func isOrIsDescendant(of ancestor: URL) -> Bool {
    guard ancestor.isFileURL, self.isFileURL else {
      return false
    }

    let ancestorComponents = ancestor.pathComponents
    let selfComponents = self.pathComponents

    guard selfComponents.count >= ancestorComponents.count else {
      return false
    }

    for (index, component) in ancestorComponents.enumerated() {
      if selfComponents[index] != component {
        return false
      }
    }

    return true
  }
}

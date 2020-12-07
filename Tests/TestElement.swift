import Foundation

struct TestElement<T: Hashable>: Identifiable, Equatable {
  let id: T
  var content: T
}

extension TestElement {
  init(id: T) {
    self.id = id
    self.content = id
  }
}

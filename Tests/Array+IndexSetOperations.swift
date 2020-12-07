import Foundation

extension Array {
  mutating func remove(at indexes: IndexSet) {
    var offset = 0
    for index in indexes {
      remove(at: index - offset)
      offset += 1
    }
  }
}

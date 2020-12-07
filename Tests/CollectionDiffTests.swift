import Foundation
import OptiDiff
import XCTest

extension Array {
  @inlinable func keyed<Key: Hashable>(by keyForValue: (Element) -> Key) -> [Key: Element] {
    reduce(into: [:]) { result, element in
      let key = keyForValue(element)
      precondition(result[key] == nil)
      result[key] = element
    }
  }
}

extension CollectionDiff {
  var movedFrom: [Indexes.Element: Indexes.Element] {
    moves.keyed(by: \.to).mapValues(\.from)
  }
}

final class CollectionDiffTests: XCTestCase {
  func test_emptyFromEmpty() {
    let old = [Int]()
    let new = [Int]()

    let diff = new.difference(from: old)

    XCTAssertEqual(diff.removals, [])
    XCTAssertEqual(diff.insertions, [])
    XCTAssertEqual(diff.moves, [])
    XCTAssertEqual(diff.updatesAfter, [])
    XCTAssertEqual(diff.updatesBefore, [])
  }

  func test_emptyFromNonEmpty() {
    let old = [0, 1, 2]
    let new = [Int]()

    let diff = new.difference(from: old)

    XCTAssertEqual(diff.removals, IndexSet(old.indices))
    XCTAssertEqual(diff.insertions, [])
    XCTAssertEqual(diff.moves, [])
    XCTAssertEqual(diff.updatesAfter, [])
    XCTAssertEqual(diff.updatesBefore, [])
  }

  func test_nonEmptyFromEmpty() {
    let old = [Int]()
    let new = [0, 1, 2]

    let diff = new.difference(from: old)

    XCTAssertEqual(diff.removals, [])
    XCTAssertEqual(diff.insertions, IndexSet(new.indices))
    XCTAssertEqual(diff.moves, [])
    XCTAssertEqual(diff.updatesAfter, [])
    XCTAssertEqual(diff.updatesBefore, [])
  }

  func test_movingBackward() {
    let old = [0, 0, 0, 3, 4, 5, 6, 7]
    let new = [6, 7, 0, 3, 4]

    let diff = new.difference(from: old)

    XCTAssertEqual(diff.removals, [1, 2, 5])
    XCTAssertEqual(diff.insertions, [])
    XCTAssertEqual(diff.movedFrom, [0: 6, 1: 7])
    XCTAssertEqual(diff.updatesAfter, [])
    XCTAssertEqual(diff.updatesBefore, [])
  }

  func test_movingForward() {
    let old = [0, 1, 2, 3, 4, 5]
    let new = [9, 9, 2, 3, 4, 0, 1]

    let diff = new.difference(from: old)

    XCTAssertEqual(diff.removals, [5])
    XCTAssertEqual(diff.insertions, [0, 1])
    XCTAssertEqual(diff.movedFrom, [5: 0, 6: 1])
    XCTAssertEqual(diff.updatesAfter, [])
    XCTAssertEqual(diff.updatesBefore, [])
  }

  func test_swapping() {
    let old = [0, 1, 2, 3, 4, 5]
    let new = [0, 4, 2, 3, 1, 5]

    let diff = new.difference(from: old)

    XCTAssertEqual(diff.removals, [])
    XCTAssertEqual(diff.insertions, [])
    XCTAssertEqual(diff.movedFrom, [1: 4, 4: 1])
    XCTAssertEqual(diff.updatesAfter, [])
    XCTAssertEqual(diff.updatesBefore, [])
  }

  func test_noMovesToSameIndex() {
    let old = [0, 1, 2, 3, 4]
    let new = [5, 6, 2, 1, 3, 4]

    let diff = new.difference(from: old)

    XCTAssertEqual(diff.removals, [0])
    XCTAssertEqual(diff.insertions, [0, 1])
    XCTAssertEqual(diff.movedFrom, [
      3: 1
    ])
    XCTAssertEqual(diff.updatesAfter, [])
    XCTAssertEqual(diff.updatesBefore, [])
  }

  func test_movingAndInsertingSameValue() {
    let old = [0, 1, 1]
    let new = [1, 0, 1, 1]

    let diff = new.difference(from: old)

    XCTAssertEqual(diff.removals, [])
    XCTAssertEqual(diff.insertions, [3])
    XCTAssertEqual(diff.movedFrom, [0: 1])
    XCTAssertEqual(diff.updatesAfter, [])
    XCTAssertEqual(diff.updatesBefore, [])
  }

  func test_randomChangesDiffCorrectness() {
    for _ in 0...10000 {
      let oldValuesRange = 0...8
      let newValuesRange = 0...10

      let old = (0..<10).map { _ in
        TestElement(id: Int.random(in: oldValuesRange))
      }

      var new = old.shuffled()

      for _ in 0..<Int.random(in: 1...3) {
        new.remove(at: .random(in: 0..<new.count))
      }

      for _ in 0..<Int.random(in: 1...3) {
        new.insert(TestElement(id: Int.random(in: newValuesRange)), at: .random(in: 0...new.count))
      }

      var updatedIndexes = IndexSet()
      for _ in 0..<Int.random(in: 1...3) {
        let index = Int.random(in: 0..<new.count)
        new[index].content = 100
        updatedIndexes.insert(index)
      }

      let diff = new.difference(from: old, identifiedBy: \.id)

      XCTAssertTrue(Set(diff.movedFrom.keys).isDisjoint(with: diff.insertions))
      XCTAssertTrue(Set(diff.movedFrom.values).isDisjoint(with: diff.removals))
      let pureInsertions = diff.insertions.subtracting(IndexSet(diff.movedFrom.keys))
      XCTAssertEqual(diff.updatesAfter, updatedIndexes.subtracting(pureInsertions))

      XCTAssertFalse(diff.moves.contains { $0.from == $0.to })

      let completeRemovals = diff.removals.union(IndexSet(diff.moves.map(\.from)))
      let completeInsertions = diff.insertions.union(IndexSet(diff.moves.map(\.to)))

      var patched1 = old
      patched1.remove(at: completeRemovals)

      for index in completeInsertions {
        let element = diff.movedFrom[index].map { old[$0] } ?? new[index]
        patched1.insert(element, at: index)
      }

      for index in diff.updatesAfter {
        patched1[index].content = 100
      }

      XCTAssertEqual(patched1, new)

      var patched2 = old

      for index in diff.updatesBefore {
        patched2[index].content = 100
      }

      patched2.remove(at: completeRemovals)

      for index in completeInsertions {
        let element = diff.movedFrom[index].map { oldIndex in
          var element = old[oldIndex]
          // We're not storing previously removed updated elements, but using original ones and updating them again.
          if diff.updatesBefore.contains(oldIndex) {
            element.content = 100
          }
          return element
        } ?? new[index]
        patched2.insert(element, at: index)
      }

      XCTAssertEqual(patched2, new)
    }
  }

  func test_performance_reversed() {
    let old = (0..<100_000).map { $0 }
    let new: [Int] = old.reversed()

    var diff: CollectionDiff<IndexSet>!

    measure {
      diff = new.difference(from: old)
    }

    XCTAssertEqual(diff.removals, [])
    XCTAssertEqual(diff.insertions, [])
    XCTAssertEqual(diff.movedFrom, [Int: Int](uniqueKeysWithValues: zip(
      IndexSet(integersIn: 0..<old.count - 1),
      IndexSet(integersIn: 1..<old.count).reversed()
    )))
    XCTAssertEqual(diff.updatesAfter, [])
    XCTAssertEqual(diff.updatesBefore, [])
  }

  func test_performance_unchangedNonRepeatingElements() {
    let old = (0..<100_000).map { $0 }
    let new = old

    var diff: CollectionDiff<IndexSet>!

    measure {
      diff = new.difference(from: old)
    }

    XCTAssertEqual(diff.removals, [])
    XCTAssertEqual(diff.insertions, [])
    XCTAssertEqual(diff.moves, [])
    XCTAssertEqual(diff.updatesAfter, [])
    XCTAssertEqual(diff.updatesBefore, [])
  }

  func test_performance_unchangedRepeatingElements() {
    let old = [Int](repeating: 1, count: 100_000)
    let new = old

    var diff: CollectionDiff<IndexSet>!

    measure {
      diff = new.difference(from: old)
    }

    XCTAssertEqual(diff.removals, [])
    XCTAssertEqual(diff.insertions, [])
    XCTAssertEqual(diff.moves, [])
    XCTAssertEqual(diff.updatesAfter, [])
    XCTAssertEqual(diff.updatesBefore, [])
  }
}

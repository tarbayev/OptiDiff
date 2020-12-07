import OptiDiff
import XCTest

final class CollectionLISTests: XCTestCase {
  func test() {
    let array = [0, 1, 2, -2, 4, -1, 6, 7]
    let lisIndexes = array.longestIncreasingSubsequenceIndexes { $0 == 4 }

    XCTAssertEqual(lisIndexes, [0, 1, 2, 6, 7])
  }

  func test_performance_increasingSequence() {
    let array = [0] + (1...300_000)

    var lisIndexes: IndexSet!
    measure {
      lisIndexes = array.longestIncreasingSubsequenceIndexes()
    }

    XCTAssertEqual(lisIndexes, IndexSet(0...300_000))
  }

  func test_performance_decreasingSequence() {
    let array = [0] + (1...300_000).reversed()

    var lisIndexes: IndexSet!
    measure {
      lisIndexes = array.longestIncreasingSubsequenceIndexes()
    }

    XCTAssertEqual(lisIndexes, [0, 300_000])
  }

  func test_performance_sameElements() {
    let array = [Int](repeating: 5, count: 300_000)

    var lisIndexes: IndexSet!
    measure {
      lisIndexes = array.longestIncreasingSubsequenceIndexes { $0 == 1 }
    }

    XCTAssertEqual(lisIndexes, [array.count - 1])
  }
}

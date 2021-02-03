import OptiDiff
import XCTest

final class CollectionLISTests: XCTestCase {
  func test1() {
    let array = [0, 2, 3, 1, 4, 5, 7, 8, 6, 9]

    XCTAssertEqual(array.longestIncreasingSubsequenceIndexes(including: []).map { array[$0] },
                   [0, 2, 3, 4, 5, 7, 8, 9])

    XCTAssertEqual(array.longestIncreasingSubsequenceIndexes(including: [3, 8]).map { array[$0] },
                   [0, 1, 4, 5, 6, 9])
  }

  func test2() {
    let array = [2, 1, 3, 4]

    XCTAssertEqual(array.longestIncreasingSubsequenceIndexes(including: []).map { array[$0] },
                   [1, 3, 4])

    XCTAssertEqual(array.longestIncreasingSubsequenceIndexes(including: [0]).map { array[$0] },
                   [2, 3, 4])
  }

  func test3() {
    let array = [5, 1, 4, 6]

    XCTAssertEqual(array.longestIncreasingSubsequenceIndexes(including: []).map { array[$0] },
                   [1, 4, 6])

    XCTAssertEqual(array.longestIncreasingSubsequenceIndexes(including: [0]).map { array[$0] },
                   [5, 6])
  }

  func test_performance_increasingSequence() {
    let array = [0] + (1...300_000)

    var lisIndexes: IndexSet!
    measure {
      lisIndexes = array.longestIncreasingSubsequenceIndexes(including: [])
    }

    XCTAssertEqual(lisIndexes, IndexSet(0...300_000))
  }

  func test_performance_decreasingSequence() {
    let array = [0] + (1...300_000).reversed()

    var lisIndexes: IndexSet!
    measure {
      lisIndexes = array.longestIncreasingSubsequenceIndexes(including: [])
    }

    XCTAssertEqual(lisIndexes, [0, 300_000])
  }

  func test_performance_sameElements() {
    let array = [Int](repeating: 5, count: 300_000)

    var lisIndexes: IndexSet!
    measure {
      lisIndexes = array.longestIncreasingSubsequenceIndexes(including: [])
    }

    XCTAssertEqual(lisIndexes, [array.count - 1])
  }
}

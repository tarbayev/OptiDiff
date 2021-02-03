import Foundation

public extension Collection where Index == Int, Element: Comparable {
  func longestIncreasingSubsequenceIndexes(including requiredIndexes: [Int]) -> IndexSet {
    if isEmpty {
      return IndexSet()
    }

    var requiredIndexIterator = requiredIndexes.makeIterator()

    var nextRequiredIndex = requiredIndexIterator.next()
    var prevRequiredIndex: Int?

    if nextRequiredIndex == 0 {
      nextRequiredIndex = requiredIndexIterator.next()
      prevRequiredIndex = 0
    }

    let previousIndexes = UnsafeMutableBufferPointer<Int>.allocate(capacity: count)
    let lengthIndexes = UnsafeMutableBufferPointer<Int>.allocate(capacity: count + 1)

    defer {
      previousIndexes.deallocate()
      lengthIndexes.deallocate()
    }

    previousIndexes[0] = lengthIndexes[0]
    lengthIndexes[1] = 0
    var length = 1

    for i in length..<count {
      let value = self[i]
      if let prev = prevRequiredIndex, value < self[prev] {
        continue
      }

      var lo = 1
      if self[lengthIndexes[length]] < value {
        lo = length + 1
      } else {
        var hi = length - 1
        while lo <= hi {
          let mid = lo + (hi - lo) / 2
          if self[lengthIndexes[mid]] < value {
            lo = mid + 1
          } else {
            hi = mid - 1
          }
        }
      }

      let newLength = lo
      previousIndexes[i] = lengthIndexes[newLength - 1]
      lengthIndexes[newLength] = i

      if i == nextRequiredIndex {
        length = newLength
        prevRequiredIndex = nextRequiredIndex
        nextRequiredIndex = requiredIndexIterator.next()
      } else if newLength > length {
        length = newLength
      }
    }

    var result = IndexSet()

    var index = lengthIndexes[length]
    for _ in 0..<length {
      result.insert(index)
      index = previousIndexes[index]
    }

    return result
  }
}

import Foundation

public extension Collection where Index == Int {
  func longestIncreasingSubsequenceIndexes(areInIncreasingOrder: (Element, Element) -> Bool,
                                           skipWhere shouldSkip: (Element) -> Bool) -> IndexSet {
    var length = 0

    let previousIndexes = UnsafeMutableBufferPointer<Int>.allocate(capacity: count)
    let lengthIndexes = UnsafeMutableBufferPointer<Int>.allocate(capacity: count + 1)

    if count > 0 {
      previousIndexes[0] = lengthIndexes[0]
      lengthIndexes[1] = 0
      length = 1
    }

    let start = length

    for i in start..<count {

      if shouldSkip(self[i]) {
        continue
      }

      var lo = 1
      if areInIncreasingOrder(self[lengthIndexes[length]], self[i]) {
        lo = length + 1
      } else {
        var hi = length - 1
        while lo <= hi {
          let mid = lo + (hi - lo) / 2
          if areInIncreasingOrder(self[lengthIndexes[mid]], self[i]) {
            lo = mid + 1
          } else {
            hi = mid - 1
          }
        }
      }

      let newLength = lo

      previousIndexes[i] = lengthIndexes[newLength - 1]
      lengthIndexes[newLength] = i

      if newLength > length {
        length = newLength
      }
    }

    var result = IndexSet()

    var index = lengthIndexes[length]
    for _ in 0..<length {
      result.insert(index)
      index = previousIndexes[index]
    }

    previousIndexes.deallocate()
    lengthIndexes.deallocate()

    return result
  }

  func longestIncreasingSubsequenceIndexes<T: Comparable>(comparedBy comparedValue: (Element) -> T,
                                                          skipWhere shouldSkip: (Element) -> Bool) -> IndexSet {
    longestIncreasingSubsequenceIndexes(
      areInIncreasingOrder: { comparedValue($0) < comparedValue($1) },
      skipWhere: shouldSkip
    )
  }
}

public extension Collection where Index == Int, Element: Comparable {
  func longestIncreasingSubsequenceIndexes(skipWhere shouldSkip: (Element) -> Bool = { _ in false }) -> IndexSet {
    longestIncreasingSubsequenceIndexes(areInIncreasingOrder: <, skipWhere: shouldSkip)
  }
}

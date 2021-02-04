import Foundation

public extension Collection where Index == Int {
  func difference<H>(from old: Self,
                     identifiedBy identifier: (Element) -> H,
                     areEqualAt: (_ oldIndex: Index, _ newIndex: Index) -> Bool) -> CollectionDiff<IndexSet>
    where H: Hashable {
    var oldIndexes: [H: [Index]] = old.enumerated().reversed().reduce(into: [:]) { result, entry in
      result[identifier(entry.element), default: []].append(entry.offset)
    }

    var newIndexCounts: [H: Int] = reduce(into: [:]) { result, element in
      result[identifier(element), default: 0] += 1
    }

    var removals = IndexSet()
    var insertions = IndexSet()
    var updates = IndexSet()
    var updatesBefore = IndexSet()

    for (index, element) in old.enumerated() {
      let key = identifier(element)
      if let count = newIndexCounts[key], count > 0 {
        newIndexCounts[key] = count - 1
      } else {
        removals.insert(index)
      }
    }

    typealias Move = CollectionDiff<IndexSet>.Move
    var allMoves: [Move] = []
    var unchangedIndexes: [Int] = []

    for (index, element) in enumerated() {
      let key = identifier(element)
      if let oldIndex = oldIndexes[key]?.popLast() {
        allMoves.append(Move(from: oldIndex, to: index))
        if oldIndex == index {
          unchangedIndexes.append(allMoves.count - 1)
        }
        if !areEqualAt(oldIndex, index) {
          updates.insert(index)
          updatesBefore.insert(oldIndex)
        }
      } else {
        insertions.insert(index)
      }
    }

    let naturalMoveIndexes = allMoves.map(\.from)
      .longestIncreasingSubsequenceIndexes(including: unchangedIndexes)

    let allMoveIndexes = IndexSet(integersIn: 0..<allMoves.count)
    let actualMoveIndexes = allMoveIndexes.subtracting(naturalMoveIndexes)

    let moves = actualMoveIndexes.map { allMoves[$0] }

    return CollectionDiff(
      removals: removals,
      insertions: insertions,
      moves: moves,
      updatesAfter: updates,
      updatesBefore: updatesBefore
    )
  }

  func difference<H>(from old: Self,
                     identifiedBy identifier: (Element) -> H,
                     areEqual: (Element, Element) -> Bool) -> CollectionDiff<IndexSet>
    where H: Hashable {
    difference(from: old, identifiedBy: identifier) { areEqual(old[$0], self[$1]) }
  }
}

public extension Collection where Index == Int, Element: Hashable {
  func difference(from old: Self) -> CollectionDiff<IndexSet> {
    difference(from: old, identifiedBy: { $0 }, areEqual: ==)
  }
}

public extension Collection where Index == Int, Element: Equatable {
  func difference<H: Hashable>(from old: Self, identifiedBy identifier: (Element) -> H) -> CollectionDiff<IndexSet> {
    difference(from: old, identifiedBy: identifier, areEqual: ==)
  }
}

@available(OSX 10.15, *)
@available(iOS 13, *)
public extension Collection where Index == Int, Element: Identifiable, Element: Equatable {
  func difference(from old: Self) -> CollectionDiff<IndexSet> {
    difference(from: old, identifiedBy: \.id, areEqual: ==)
  }
}

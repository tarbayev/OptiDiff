import Foundation

public extension Collection where Index == Int {
  func difference<H>(from old: Self,
                     identifiedBy identifier: (Element) -> H,
                     areEqualAt: (_ oldIndex: Index, _ newIndex: Index) -> Bool) -> CollectionDiff<IndexSet>
    where H: Hashable {
    var oldIndexes: [H: [Index]] = old.indices.reversed().reduce(into: [:]) { result, index in
      result[identifier(old[index]), default: []].append(index)
    }

    var newIndexCounts: [H: Int] = reduce(into: [:]) { result, element in
      result[identifier(element), default: 0] += 1
    }

    var removals = IndexSet()
    var insertions = IndexSet()
    var updates = IndexSet()
    var updatesBefore = IndexSet()

    for index in old.indices {
      let key = identifier(old[index])
      if let count = newIndexCounts[key], count > 0 {
        newIndexCounts[key] = count - 1
      } else {
        removals.insert(index)
      }
    }

    typealias Move = CollectionDiff<IndexSet>.Move
    var allMoves: [Move] = []
    var unchangedIndexes = IndexSet()

    for index in indices {
      let key = identifier(self[index])
      if let oldIndex = oldIndexes[key]?.popLast() {
        allMoves.append(Move(from: oldIndex, to: index))
        if oldIndex == index {
          unchangedIndexes.insert(index)
        }
        if !areEqualAt(oldIndex, index) {
          updates.insert(index)
          updatesBefore.insert(oldIndex)
        }
      } else {
        insertions.insert(index)
      }
    }

    let naturalMoveIndexes = allMoves
      .longestIncreasingSubsequenceIndexes(
        comparedBy: \.from,
        skipWhere: { move in
          if let nextUnchanged = unchangedIndexes.integerGreaterThan(move.to), move.from > nextUnchanged {
            return true
          }
          if let prevUnchanged = unchangedIndexes.integerLessThan(move.to), move.from < prevUnchanged {
            return true
          }
          return false
        }
      )

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

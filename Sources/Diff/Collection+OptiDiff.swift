import Foundation

public extension Collection where Index == Int {
  func rawDifference<H>(
    from old: Self,
    identifiedBy identifier: (Element) -> H,
    areEqual: (Element, Element) -> Bool
  ) -> CollectionDiff<IndexSet>
    where H: Hashable {
    var oldIndexes: [H: [Index]] = old.enumerated().reversed().reduce(into: [:]) { result, entry in
      result[identifier(entry.element), default: []].append(entry.offset)
    }

    var removals = IndexSet(0..<old.count)
    var insertions = IndexSet()
    var updatesAfter = IndexSet()
    var updatesBefore = IndexSet()

    typealias Move = CollectionDiff<IndexSet>.Move
    var allMoves: [Move] = []

    for (index, element) in enumerated() {
      let key = identifier(element)
      if let oldIndex = oldIndexes[key]?.popLast() {
        removals.remove(oldIndex)
        allMoves.append(Move(from: oldIndex, to: index))
        if !areEqual(old[oldIndex], element) {
          updatesAfter.insert(index)
          updatesBefore.insert(oldIndex)
        }
      } else {
        insertions.insert(index)
      }
    }

    return CollectionDiff(
      removals: removals,
      insertions: insertions,
      moves: allMoves,
      updatesAfter: updatesAfter,
      updatesBefore: updatesBefore
    )
  }

  func difference<H>(
    from old: Self,
    identifiedBy identifier: (Element) -> H,
    areEqual: (Element, Element) -> Bool
  ) -> CollectionDiff<IndexSet>
    where H: Hashable {
    rawDifference(from: old, identifiedBy: identifier, areEqual: areEqual).optimizingMoves()
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

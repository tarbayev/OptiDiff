import Foundation

public extension Collection where Index == Int {
  func sectionedDifference<ID, Item, CID>(from old: Self,
                                          identifiedBy identifier: (Element) -> ID,
                                          areEqual: (Element, Element) -> Bool,
                                          items: (Element) -> [Item],
                                          identifiedBy itemIdentifier: (Item) -> CID,
                                          areEqual areItemsEqual: (Item, Item) -> Bool) -> SectionedCollectionDiff
    where ID: Hashable, CID: Hashable {
    var removedChildren: [CID: [IndexPath]] = [:]
    var insertedChildren: [CID: [IndexPath]] = [:]

    typealias Move = CollectionDiff<Set<IndexPath>>.Move
    var childMoves: [Move] = []
    var childUpdatesBefore: [IndexPath] = []
    var childUpdatesAfter: [IndexPath] = []

    let rawDiff: CollectionDiff<IndexSet> = rawDifference(from: old, identifiedBy: identifier, areEqual: areEqual)

    for move in rawDiff.moves {
      let oldElement = old[move.from]
      let newElement = self[move.to]
      let oldItems = items(oldElement)
      let newItems = items(newElement)
      let itemDiff: CollectionDiff<IndexSet> = newItems.difference(from: oldItems, identifiedBy: itemIdentifier, areEqual: areItemsEqual)

      for index in itemDiff.removals {
        removedChildren[itemIdentifier(oldItems[index]), default: []].append(IndexPath(indexes: [move.from, index]))
      }

      for index in itemDiff.insertions {
        insertedChildren[itemIdentifier(newItems[index]), default: []].append(IndexPath(indexes: [move.to, index]))
      }

      childMoves += itemDiff.moves.map {
        Move(
          from: IndexPath(indexes: [move.from, $0.from]),
          to: IndexPath(indexes: [move.to, $0.to])
        )
      }

      childUpdatesBefore += itemDiff.updatesBefore.map { IndexPath(indexes: [move.from, $0]) }
      childUpdatesAfter += itemDiff.updatesAfter.map { IndexPath(indexes: [move.to, $0]) }
    }

    var childRemovals: [IndexPath] = []
    var childInsertions: [IndexPath] = []

    for (childID, indexes) in removedChildren {
      for removedIndexPath in indexes {
        if let insertedIndexPath = insertedChildren[childID]?.popLast() {
          childMoves.append(Move(from: removedIndexPath, to: insertedIndexPath))
          if !areItemsEqual(
            items(old[removedIndexPath[0]])[removedIndexPath[1]],
            items(self[insertedIndexPath[0]])[insertedIndexPath[1]]
          ) {
            childUpdatesBefore.append(removedIndexPath)
            childUpdatesAfter.append(insertedIndexPath)
          }
        } else {
          childRemovals.append(removedIndexPath)
        }
      }
    }

    for indexes in insertedChildren.values {
      childInsertions += indexes
    }

    return SectionedCollectionDiff(
      section: rawDiff.optimizingMoves(),
      item: .init(
        removals: Set(childRemovals),
        insertions: Set(childInsertions),
        moves: childMoves,
        updatesAfter: Set(childUpdatesAfter),
        updatesBefore: Set(childUpdatesBefore)
      )
    )
  }

  func sectionedDifference<ID, Item, CID, SectionValue, ItemValue>(from old: Self,
                                                                   identifiedBy identifier: (Element) -> ID,
                                                                   areEqualBy sectionValue: (Element) -> SectionValue,
                                                                   items: (Element) -> [Item],
                                                                   identifiedBy itemIdentifier: (Item) -> CID,
                                                                   areEqualBy itemValue: (Item) -> ItemValue) -> SectionedCollectionDiff
    where ID: Hashable, CID: Hashable, SectionValue: Equatable, ItemValue: Equatable {
    sectionedDifference(
      from: old,
      identifiedBy: identifier,
      areEqual: { sectionValue($0) == sectionValue($1) },
      items: items,
      identifiedBy: itemIdentifier,
      areEqual: { itemValue($0) == itemValue($1) }
    )
  }
}

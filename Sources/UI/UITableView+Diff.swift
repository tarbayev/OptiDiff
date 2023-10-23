import UIKit

public struct TableViewAnimations {
  public typealias Animation = UITableView.RowAnimation

  public var sectionDelete = Animation.automatic
  public var sectionInsert = Animation.automatic
  public var sectionReload = Animation.automatic

  public var rowDelete = Animation.automatic
  public var rowInsert = Animation.automatic
  public var rowReload = Animation.automatic
}

public extension TableViewAnimations {
  static func automatic() -> Self {
    TableViewAnimations()
  }
}

public extension UITableView {
  func performUpdates(
    with diff: SectionedCollectionDiff,
    animations: TableViewAnimations = .automatic(),
    completion: @escaping () -> Void
  ) {
    guard window != nil else {
      reloadData()
      return
    }

    let movedFromSections = IndexSet(diff.section.moves.map(\.from))

    var sectionUpdates = diff.section.updatesBefore
    var sectionInsertions = diff.section.insertions
    var sectionRemovals = diff.section.removals
    var rowInsertions = diff.item.insertions
    var rowRemovals = diff.item.removals
    var rowUpdates = diff.item.updatesBefore

    var finalUpdatedSectionIndexes = IndexSet()

    for move in diff.item.moves {
      if movedFromSections.contains(move.from.section) {
        sectionUpdates.insert(move.from.section)
        finalUpdatedSectionIndexes.insert(move.to.section)
        rowInsertions.insert(move.to)
      }
    }

    for indexPath in rowRemovals {
      let section = indexPath.section
      if movedFromSections.contains(section) {
        sectionUpdates.insert(section)
      }
    }

    let sectionMoves = diff.section.moves.filter { move in
      if sectionUpdates.remove(move.from) == nil {
        return true
      }
      sectionRemovals.insert(move.from)
      sectionInsertions.insert(move.to)
      return false
    }

    let rowMoves = diff.item.moves.filter { move in
      if sectionRemovals.contains(move.from.section), !sectionInsertions.contains(move.to.section) {
        rowInsertions.insert(move.to)
        return false
      }

      if sectionInsertions.contains(move.to.section), !sectionRemovals.contains(move.from.section) {
        rowRemovals.insert(move.from)
        return false
      }

      if finalUpdatedSectionIndexes.contains(move.to.section) {
        rowRemovals.insert(move.from)
        return false
      }

      if sectionUpdates.contains(move.from.section) {
        return false
      }

      if rowUpdates.remove(move.from) == nil {
        return true
      }

      rowRemovals.insert(move.from)
      rowInsertions.insert(move.to)
      return false
    }

    performBatchUpdates {
      deleteSections(sectionRemovals, with: animations.sectionDelete)
      insertSections(sectionInsertions, with: animations.sectionInsert)

      deleteRows(at: Array(rowRemovals), with: animations.rowDelete)
      insertRows(at: Array(rowInsertions), with: animations.rowInsert)

      for move in sectionMoves {
        moveSection(move.from, toSection: move.to)
      }

      for move in rowMoves {
        moveRow(at: move.from, to: move.to)
      }

      if !rowUpdates.isEmpty {
        reloadRows(at: Array(rowUpdates), with: animations.rowReload)
      }

      if !sectionUpdates.isEmpty {
        reloadSections(sectionUpdates, with: animations.sectionReload)
      }
    } completion: { _ in
      completion()
    }
  }
}

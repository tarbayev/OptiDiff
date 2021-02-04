import Foundation

public struct CollectionDiff<Indexes: Sequence> where Indexes.Element: Hashable {
  public let removals: Indexes
  public let insertions: Indexes
  public let moves: [Move]
  public let updatesAfter: Indexes
  public let updatesBefore: Indexes

  public struct Move: Hashable {
    public let from: Indexes.Element
    public let to: Indexes.Element
  }
}

extension CollectionDiff: Equatable where Indexes: Equatable {}

extension CollectionDiff where Indexes == IndexSet {
  func optimizingMoves() -> Self {
    let unchangedIndexes = moves.enumerated().compactMap { $0.element.from == $0.element.to ? $0.offset : nil }

    let naturalMoveIndexes = moves.map(\.from)
      .longestIncreasingSubsequenceIndexes(including: unchangedIndexes)

    let allMoveIndexes = IndexSet(integersIn: 0..<moves.count)
    let actualMoveIndexes = allMoveIndexes.subtracting(naturalMoveIndexes)

    let optimalMoves = actualMoveIndexes.map { moves[$0] }

    return CollectionDiff(
      removals: removals,
      insertions: insertions,
      moves: optimalMoves,
      updatesAfter: updatesAfter,
      updatesBefore: updatesBefore
    )
  }
}

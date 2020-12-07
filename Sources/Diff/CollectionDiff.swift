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

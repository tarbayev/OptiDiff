import Foundation

public struct SectionedCollectionDiff {
  public let section: CollectionDiff<IndexSet>
  public let item: CollectionDiff<Set<IndexPath>>
}

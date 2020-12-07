import OptiDiff
import XCTest

struct Section {
  let value: TestElement<String>
  let items: [TestElement<String>]
}

final class SectionedDiffTests: XCTestCase {
  func test_movesSectionsAndItems() {
    let sections1 = [
      Section(value: .init(id: "0"), items: [
        .init(id: "0.0"),
        .init(id: "0.1"),
        .init(id: "0.2")
      ]),
      Section(value: .init(id: "1"), items: [
        .init(id: "1.0"),
        .init(id: "1.1"),
        .init(id: "1.2")
      ])
    ]

    let sections2 = [
      Section(value: .init(id: "1"), items: [
        .init(id: "1.0"),
        .init(id: "1.1"),
        .init(id: "0.2 Inserted")
      ]),
      Section(value: .init(id: "0", content: "Updated"), items: [
        .init(id: "0.0", content: "Updated"),
        .init(id: "0.2"),
        .init(id: "1.2", content: "Updated")
      ])
    ]

    let diff = sections2.sectionedDifference(
      from: sections1,
      identifiedBy: \.value.id,
      areEqualBy: \.value,
      items: \.items,
      identifiedBy: \.id,
      areEqualBy: { $0 }
    )

    XCTAssertEqual(diff.section.movedFrom, [
      0: 1
    ])
    XCTAssertEqual(diff.section.removals, [])
    XCTAssertEqual(diff.section.insertions, [])
    XCTAssertEqual(diff.section.updatesAfter, [1])
    XCTAssertEqual(diff.section.updatesBefore, [0])

    XCTAssertEqual(diff.item.movedFrom, [
      IndexPath(item: 2, section: 1): IndexPath(item: 2, section: 1)
    ])
    XCTAssertEqual(diff.item.removals, [IndexPath(item: 1, section: 0)])
    XCTAssertEqual(diff.item.insertions, [IndexPath(item: 2, section: 0)])
    XCTAssertEqual(diff.item.updatesAfter, [
      IndexPath(item: 0, section: 1),
      IndexPath(item: 2, section: 1)
    ])
    XCTAssertEqual(diff.item.updatesBefore, [
      IndexPath(item: 0, section: 0),
      IndexPath(item: 2, section: 1)
    ])
  }
}

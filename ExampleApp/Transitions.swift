import Foundation

struct Transition {
  var from: [Section]
  var to: [Section]
}

extension Transition {
  static let defaultSections = [
    Section(id: 0, items: [
      Item(id: 0, value: 0),
      Item(id: 1, value: 0)
    ]),
    Section(id: 1, items: [
      Item(id: 10, value: 0),
      Item(id: 11, value: 0),
      Item(id: 12, value: 0)
    ])
  ]

  static var moveItem: Self {
    Transition(from: defaultSections, to: [
      Section(id: 0, items: [
        Item(id: 0, value: 0),
        Item(id: 11, value: 0),
        Item(id: 1, value: 0)
      ]),
      Section(id: 1, items: [
        Item(id: 10, value: 0),
        Item(id: 12, value: 0)
      ])
    ])
  }

  static var moveAndUpdateItem: Self {
    Transition(from: defaultSections, to: [
      Section(id: 0, items: [
        Item(id: 11, value: 1),
        Item(id: 0, value: 0),
        Item(id: 1, value: 0)
      ]),
      Section(id: 1, items: [
        Item(id: 10, value: 0),
        Item(id: 12, value: 0)
      ])
    ])
  }

  static var moveSection: Self {
    Transition(from: defaultSections, to: [
      Section(id: 1, items: [
        Item(id: 10, value: 0),
        Item(id: 11, value: 0),
        Item(id: 12, value: 0)
      ]),
      Section(id: 0, items: [
        Item(id: 0, value: 0),
        Item(id: 1, value: 0)
      ])
    ])
  }

  static var moveItemsInAndOutOfMovedSection: Self {
    Transition(from: defaultSections, to: [
      Section(id: 1, items: [
        Item(id: 10, value: 0),
        Item(id: 12, value: 0),
        Item(id: 1, value: 0)
      ]),
      Section(id: 0, items: [
        Item(id: 0, value: 0),
        Item(id: 11, value: 0)
      ])
    ])
  }

  static var moveItemIntoMovedSection: Self {
    Transition(from: defaultSections, to: [
      Section(id: 1, items: [
        Item(id: 10, value: 0),
        Item(id: 11, value: 0),
        Item(id: 12, value: 0),
        Item(id: 1, value: 0)
      ]),
      Section(id: 0, items: [
        Item(id: 0, value: 0)
      ])
    ])
  }

  static var moveItemOutOfMovedSection: Self {
    Transition(from: defaultSections, to: [
      Section(id: 1, items: [
        Item(id: 10, value: 0),
        Item(id: 12, value: 0)
      ]),
      Section(id: 0, items: [
        Item(id: 0, value: 0),
        Item(id: 11, value: 0),
        Item(id: 1, value: 0)
      ])
    ])
  }

  static var moveItemWithinMovedSection: Self {
    Transition(from: defaultSections, to: [
      Section(id: 1, items: [
        Item(id: 12, value: 0),
        Item(id: 10, value: 0),
        Item(id: 11, value: 0)
      ]),
      Section(id: 0, items: [
        Item(id: 1, value: 0),
        Item(id: 0, value: 0)
      ])
    ])
  }

  static var removeItemOutOfMovedSection: Self {
    Transition(from: defaultSections, to: [
      Section(id: 1, items: [
        Item(id: 10, value: 0),
        Item(id: 12, value: 0)
      ]),
      Section(id: 0, items: [
        Item(id: 0, value: 0),
        Item(id: 1, value: 0)
      ])
    ])
  }

  static var insertItemIntoMovedSection: Self {
    Transition(from: defaultSections, to: [
      Section(id: 1, items: [
        Item(id: 10, value: 0),
        Item(id: 11, value: 0),
        Item(id: 12, value: 0),
        Item(id: 13, value: 0)
      ]),
      Section(id: 0, items: [
        Item(id: 0, value: 0),
        Item(id: 1, value: 0),
        Item(id: 2, value: 0)
      ])
    ])
  }

  static var moveAndUpdateSection: Self {
    Transition(from: defaultSections, to: [
      Section(id: 1, value: 100, items: [
        Item(id: 10, value: 0),
        Item(id: 11, value: 0),
        Item(id: 12, value: 0)
      ]),
      Section(id: 0, items: [
        Item(id: 0, value: 0),
        Item(id: 1, value: 0)
      ])
    ])
  }
}

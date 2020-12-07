import UIKit

struct Section: Hashable {
  var id: Int = .random(in: 0...Int.max)
  var value: Int = 0
  var items: [Item]
}

struct Item: Hashable {
  var id: Int = .random(in: 0...255)
  var color: UIColor {
    UIColor(hue: CGFloat(id) / 16, saturation: 1, brightness: 1, alpha: 1)
  }

  var value: Int = 0
}

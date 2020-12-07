import UIKit

class Cell: UITableViewCell {
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    backgroundView = UIView()
  }
}

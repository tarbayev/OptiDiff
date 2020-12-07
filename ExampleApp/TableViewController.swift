import OptiDiff
import UIKit

class TableViewController: UITableViewController {

  var sections: [Section] = []

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    performNextTransition()
  }

  let transitions: [Transition] = [
    .moveItemWithinMovedSection,
    .insertItemIntoMovedSection,
    .removeItemOutOfMovedSection,
    .moveItemOutOfMovedSection,
    .moveItemIntoMovedSection,
    .moveItemsInAndOutOfMovedSection,
    .moveAndUpdateSection,
    .moveSection,
    .moveItem,
    .moveAndUpdateItem
  ]

  var nextTransitionIndex = 0

  func nextTransition() -> Transition? {
    if nextTransitionIndex < transitions.count {
      defer {
        nextTransitionIndex += 1
      }
      return transitions[nextTransitionIndex]
    }
    return nil
  }

  func performNextTransition() {
    guard let transition = nextTransition() else {
      title = "Done"
      return
    }

    title = "\(nextTransitionIndex)"

    sections = transition.from
    tableView.reloadData()
    tableView.layoutIfNeeded()

    update(with: transition.to) { [weak self] in
      self?.performNextTransition()
    }
  }

  func update(with newSections: [Section], completion: @escaping () -> Void) {
    let oldSections = sections
    sections = newSections
    tableView.performUpdates(
      with: sections.sectionedDifference(
        from: oldSections,
        identifiedBy: \.id,
        areEqualBy: \.value,
        items: \.items,
        identifiedBy: \.id,
        areEqualBy: \.value
      ),
      completion: completion
    )
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    sections.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    sections[section].items.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell

    let item = sections[indexPath.section].items[indexPath.row]

    cell.backgroundView?.backgroundColor = item.color
    cell.textLabel?.text = "\(item.id) - \(item.value)"

    return cell
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let section = sections[section]
    return "\(section.id) - \(section.value)"
  }
}

import UIKit

class EventSearchBarController: UIViewController {
    let searchBar = UISearchBar()

    override func viewDidLoad() {
        view.addSubview(searchBar)

        setupConstraints()
    }

    private func setupConstraints() {
        searchBar.autoPinEdgesToSuperviewMargins()
        searchBar.placeholder = "what uppppp"
    }
}

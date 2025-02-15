//
//  CommonMenuViewController.swift
//  HouseholdBudgetCalculator
//
//  Created by ウルトラ深瀬 on 14/2/25.
//

import UIKit

class CommonMenuViewController: UIViewController {
    struct CommonMenuItem {
        let title: String
        let onSelected: () -> Void
    }
    
    let menuItems: [CommonMenuItem]
    
    init(menuItems: [CommonMenuItem]) {
        self.menuItems = menuItems
        super.init(nibName: CommonMenuViewController.className, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: CommonMenuCell.className, bundle: .main), forCellReuseIdentifier: CommonMenuCell.className)
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension CommonMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommonMenuCell.className, for: indexPath) as! CommonMenuCell
        cell.titleLabel.text = menuItems[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.menuItems[indexPath.row].onSelected()
        }
    }
}

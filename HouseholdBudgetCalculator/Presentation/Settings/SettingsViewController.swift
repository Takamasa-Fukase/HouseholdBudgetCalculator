//
//  SettingsViewController.swift
//  HouseholdBudgetCalculator
//
//  Created by ウルトラ深瀬 on 14/2/25.
//

import UIKit

class SettingsViewController: UIViewController {
    let googleLoginSelected: () -> Void
    let jsonDumpSelected: () -> Void
    
    init(
        googleLoginSelected: @escaping () -> Void,
        jsonDumpSelected: @escaping () -> Void
    ) {
        self.googleLoginSelected = googleLoginSelected
        self.jsonDumpSelected = jsonDumpSelected
        super.init(nibName: SettingsViewController.className, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: SettingsCell.className, bundle: .main), forCellReuseIdentifier: SettingsCell.className)
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.className, for: indexPath) as! SettingsCell
        switch indexPath.row {
        case 0:
            cell.label.text = "Googleカレンダーを連携"
        case 1:
            cell.label.text = "JSONファイルに書き出して共有"
        default:
            cell.label.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
            
        case 1:
            dismiss(animated: true) {
                self.jsonDumpSelected()
            }
            break
            
        default:
            break
        }
    }
}

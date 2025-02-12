//
//  MonthListViewController.swift
//  HouseholdBudgetCalculator
//
//  Created by ウルトラ深瀬 on 12/2/25.
//

import UIKit

class MonthListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    init() {
        super.init(nibName: MonthListViewController.className, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "月を選択"
        setupTableView()
        createDataIfNotExists()
        tableView.reloadData()
    }
    
    private func createDataIfNotExists() {
        // データがまだ存在しない場合は追加
        if UserDefaults.monthlyExpenses.isEmpty {
            UserDefaults.monthlyExpenses = [
                .init(
                    title: "2025年2月",
                    expenseGroups: [
                        .init(title: "スーパー",
                              budgetAmount: 25000,
                              items: [
                                .init(title: "", amount: 0)
                              ]),
                        .init(title: "1人外食",
                              budgetAmount: 3000,
                              items: [
                                .init(title: "", amount: 0)
                              ]),
                        .init(title: "コンビニ・自販機",
                              budgetAmount: 2000,
                              items: [
                                .init(title: "", amount: 0)
                              ]),
                        .init(title: "カラオケ",
                              budgetAmount: 3000,
                              items: [
                                .init(title: "", amount: 0)
                              ]),
                        .init(title: "1人カフェ",
                              budgetAmount: 10000,
                              items: [
                                .init(title: "", amount: 0)
                              ]),
                        .init(title: "友達との交際費",
                              budgetAmount: 30000,
                              items: [
                                .init(title: "", amount: 0)
                              ])
                    ]
                )
            ]
        }
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: MonthListCell.className, bundle: .main), forCellReuseIdentifier: MonthListCell.className)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.top = 16
    }
}

extension MonthListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserDefaults.monthlyExpenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MonthListCell.className, for: indexPath) as! MonthListCell
        cell.dateLabel.text = UserDefaults.monthlyExpenses[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ExpenseGroupListViewController()
        vc.monthlyExpense = UserDefaults.monthlyExpenses[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

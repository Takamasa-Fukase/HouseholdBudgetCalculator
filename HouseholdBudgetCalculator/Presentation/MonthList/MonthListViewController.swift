//
//  MonthListViewController.swift
//  HouseholdBudgetCalculator
//
//  Created by ウルトラ深瀬 on 12/2/25.
//

import UIKit

class MonthListViewController: UIViewController {
    private var monthlyExpenses: [MonthlyExpense] = []

    @IBOutlet weak var tableView: UITableView!
    
    init() {
        super.init(nibName: MonthListViewController.className, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        monthlyExpenses = UserDefaults.monthlyExpenses
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: MonthListCell.className, bundle: .main), forCellReuseIdentifier: MonthListCell.className)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.top = 32
    }
}

extension MonthListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthlyExpenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: MonthListCell.className, for: indexPath) as! MonthListCell
        cell.dateLabel.text = monthlyExpenses[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 画面遷移
    }
}

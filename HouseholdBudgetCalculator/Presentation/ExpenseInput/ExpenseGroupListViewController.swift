//
//  ExpenseGroupListViewController.swift
//  HouseholdBudgetCalculator
//
//  Created by ウルトラ深瀬 on 12/2/25.
//

import UIKit
import Parchment

class ExpenseGroupListViewController: UIViewController {
    var monthlyExpense: MonthlyExpense = .init(title: "", expenseGroups: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        title = monthlyExpense.title
        view.backgroundColor = .systemBackground
    }
}

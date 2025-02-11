//
//  MonthlyExpense.swift
//  HouseholdBudgetCalculator
//
//  Created by ウルトラ深瀬 on 11/2/25.
//

import Foundation

struct MonthlyExpense: Codable {
    let id: UUID = UUID()
    let title: String
    var expenseGroups: [ExpenseGroup]
}

struct ExpenseGroup: Codable {
    let id: UUID = UUID()
    let title: String
    var items: [ExpenseItem]
}

struct ExpenseItem: Codable {
    let id: UUID = UUID()
    var title: String
    var amount: Int
}

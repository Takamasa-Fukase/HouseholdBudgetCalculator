//
//  MonthlyExpense.swift
//  HouseholdBudgetCalculator
//
//  Created by ウルトラ深瀬 on 11/2/25.
//

import Foundation

struct MonthlyExpense: Codable {
    let id: UUID
    let title: String
    var expenseGroups: [ExpenseGroup]
    
    init(title: String, expenseGroups: [ExpenseGroup]) {
        self.id = UUID()
        self.title = title
        self.expenseGroups = expenseGroups
    }
}

struct ExpenseGroup: Codable {
    let id: UUID
    let title: String
    var items: [ExpenseItem]
    
    init(title: String, items: [ExpenseItem]) {
        self.id = UUID()
        self.title = title
        self.items = items
    }
}

struct ExpenseItem: Codable {
    let id: UUID
    var title: String
    var amount: Int
    
    init(title: String, amount: Int) {
        self.id = UUID()
        self.title = title
        self.amount = amount
    }
}

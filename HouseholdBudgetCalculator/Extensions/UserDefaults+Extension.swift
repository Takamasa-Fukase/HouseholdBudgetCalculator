//
//  UserDefaults+Extension.swift
//  TravelBudgetCalculator
//
//  Created by ウルトラ深瀬 on 31/8/24.
//

import Foundation

extension UserDefaults {
    static let defaults = UserDefaults.standard

    private enum Keys {
        static let monthlyExpenses = "monthlyExpenses"
    }
    
    static var monthlyExpenses: [MonthlyExpense] {
        get {
            do {
                guard let data = defaults.data(forKey: Keys.monthlyExpenses) else {
                    return []
                }
                let decodedValue = try JSONDecoder().decode([MonthlyExpense].self, from: data)
                return decodedValue
            } catch {
                print("monthlyExpensesのget catchしたエラー: \(error)")
                return []
            }
        }
        set {
            do {
                let encodedValue = try JSONEncoder().encode(newValue)
                defaults.set(encodedValue, forKey: Keys.monthlyExpenses)
            } catch {
                print("monthlyExpensesのset catchしたエラー: \(error)")
            }
        }
    }
}

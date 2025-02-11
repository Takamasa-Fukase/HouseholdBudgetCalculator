//
//  DateDetailGenreSectionFooter.swift
//  TravelBudgetCalculator
//
//  Created by ウルトラ深瀬 on 5/9/24.
//

import UIKit

class DateDetailGenreSectionFooter: UITableViewHeaderFooterView {
    var addFormButtonTapped: (() -> Void) = {}

    @IBAction private func addFormButtonTapped(_ sender: Any) {
        addFormButtonTapped()
    }
}

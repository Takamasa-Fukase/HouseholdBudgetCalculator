//
//  ExpenseInputSectionFooter.swift
//  TravelBudgetCalculator
//
//  Created by ウルトラ深瀬 on 5/9/24.
//

import UIKit
import RxSwift
import RxCocoa

class ExpenseInputSectionFooter: UITableViewHeaderFooterView {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var formAddButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

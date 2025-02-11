//
//  PaymentListItemCell.swift
//  TravelBudgetCalculator
//
//  Created by ウルトラ深瀬 on 30/8/24.
//

import UIKit
import RxSwift
import RxCocoa

class PaymentListItemCell: UITableViewCell {    
    var disposeBag = DisposeBag()
    var id: UUID = UUID()

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var yenDisplayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupTitleTextField()
        setupAmountTextField()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    func setupTitleTextField() {
        titleTextField.returnKeyType = .done
    }
    
    func setupAmountTextField() {
        amountTextField.keyboardType = .numbersAndPunctuation
        amountTextField.returnKeyType = .done
        amountTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 0))
        amountTextField.rightViewMode = .always
    }
}

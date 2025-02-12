//
//  ExpenseInputViewController.swift
//  TravelBudgetCalculator
//
//  Created by ウルトラ深瀬 on 31/8/24.
//

import UIKit
import RxSwift
import RxCocoa
import GTProgressBar

class ExpenseInputViewController: UIViewController {
    let monthlyExpenseId: UUID
    var expenseGroup: ExpenseGroup
    var activeTextField: UIView?

    @IBOutlet weak var progressBar: GTProgressBar!
    @IBOutlet weak var usedAmountLabel: UILabel!
    @IBOutlet weak var budgetAmountLabel: UILabel!
    @IBOutlet weak var restAmountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    init(
        monthlyExpenseId: UUID,
        expenseGroup: ExpenseGroup
    ) {
        self.monthlyExpenseId = monthlyExpenseId
        self.expenseGroup = expenseGroup
        super.init(nibName: ExpenseInputViewController.className, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        updateHeaderInfo(animate: false)
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: ExpenseInputCell.className, bundle: nil), forCellReuseIdentifier: ExpenseInputCell.className)
        tableView.register(UINib(nibName: ExpenseInputSectionFooter.className, bundle: nil), forHeaderFooterViewReuseIdentifier: ExpenseInputSectionFooter.className)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInset.bottom = 200
    }

    // この画面の変数で保持しているデータをUserDefaultsに保存する
    func saveToUserDefaults() {
        var editedData = UserDefaults.monthlyExpenses
        let monthlyExpenseIndex = editedData.firstIndex(where: { $0.id == monthlyExpenseId }) ?? 0
        let expenseGroupIndex = editedData[monthlyExpenseIndex].expenseGroups.firstIndex(where: { $0.id == expenseGroup.id }) ?? 0
        editedData[monthlyExpenseIndex].expenseGroups[expenseGroupIndex] = expenseGroup
        UserDefaults.monthlyExpenses = editedData
    }
    
    private func updateHeaderInfo(animate: Bool) {
        var usedAmount: Int = 0
        expenseGroup.items.forEach({ item in
            usedAmount += item.amount
        })
        let restAmount = expenseGroup.budgetAmount - usedAmount
        usedAmountLabel.text = "累計：\(usedAmount)円"
        budgetAmountLabel.text = "予算：\(expenseGroup.budgetAmount)円"
        restAmountLabel.text = "残り：\(restAmount)円"
        var progress = CGFloat(usedAmount) / CGFloat(expenseGroup.budgetAmount)
        if progress > 1 {
            progress = 1
        }
        if animate {
            progressBar.animateTo(progress: progress)
        }else {
            progressBar.progress = progress
        }
        let progressBasedColor: UIColor = {
            switch progress {
            case 0.5..<0.8:
                return .systemYellow
            case 0.8..<1:
                return .systemOrange
            case 1:
                return .systemRed
            default:
                return .systemGreen
            }
        }()
        restAmountLabel.textColor = progressBasedColor
        progressBar.barFillColor = progressBasedColor
    }
}

extension ExpenseInputViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionFooter = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExpenseInputSectionFooter.className) as! ExpenseInputSectionFooter
        sectionFooter.formAddButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let newItem = ExpenseItem(title: "", amount: 0)
                self.expenseGroup.items.append(newItem)
                
                self.saveToUserDefaults()
                
                self.tableView.reloadSections(IndexSet(integer: section), with: .none)
            }).disposed(by: sectionFooter.disposeBag)
        return sectionFooter
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenseGroup.items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseInputCell.className, for: indexPath) as! ExpenseInputCell
        let item = expenseGroup.items[indexPath.row]
        
        // Delegateを親VCに設定
        cell.titleTextField.delegate = self
        cell.amountTextField.delegate = self
        
        cell.id = item.id
        cell.titleTextField.text = "\(item.title)"
        if item.amount == 0 {
            cell.amountTextField.text = ""
        }else {
            cell.amountTextField.text = "\(item.amount)"
        }
        
        cell.menuButton.rx.tap
            .subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            let id = cell.id
            guard let selectedItem = self.expenseGroup.items.first(where: { $0.id == id }) else {
                print("選択されたItemの取得に失敗")
                return
            }
            let message = "タイトル：\(selectedItem.title)\n金額：\(selectedItem.amount)"
            let alert = UIAlertController(
                title: "項目を削除します",
                message: message,
                preferredStyle: .alert
            )
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
            let delete = UIAlertAction(title: "削除", style: .destructive) { _ in
                let rowIndex = self.expenseGroup.items.firstIndex(where: { $0.id == id }) ?? 0
                let selectedIndexPath = IndexPath(row: rowIndex, section: 0)
                // 該当のデータを削除して画面を更新
                self.expenseGroup.items.remove(at: selectedIndexPath.row)
                
                self.saveToUserDefaults()
                
//                self.tableView.reloadRows(at: [indexPath], with: .none)
                // セクションヘッダーに表示してる金額も更新したいので、
                // 単体でのdeleteRowsではなくsectionを丸ごと更新している
                self.tableView.deleteRows(at: [indexPath], with: .none)
                self.updateHeaderInfo(animate: true)
            }
            alert.addAction(cancel)
            alert.addAction(delete)
            self.present(alert, animated: true)
            }).disposed(by: cell.disposeBag)
        
        cell.titleTextField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            let title = cell.titleTextField.text ?? ""
            self.expenseGroup.items[indexPath.row].title = title
            
            self.saveToUserDefaults()
            
            /*
             項目名の入力後に完了をおさずにそのまま金額のフォームに移動するときにも更新してしまうと、金額のフォームのカーソルが消えてしまうバグがあるので、このタイミングでは更新しない。データソース自体は書き換えているので問題ないと思われる。
             */
//                self.tableView.reloadRows(at: [indexPath], with: .none)
            }).disposed(by: cell.disposeBag)
        
        cell.amountTextField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            self.expenseGroup.items[indexPath.row].title = cell.titleTextField.text ?? ""
            self.expenseGroup.items[indexPath.row].amount = Int(cell.amountTextField.text ?? "0") ?? 0
            
            self.saveToUserDefaults()
                            
                self.tableView.reloadRows(at: [indexPath], with: .none)
                self.updateHeaderInfo(animate: true)
            }).disposed(by: cell.disposeBag)
        
        return cell
    }
}

extension ExpenseInputViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
}

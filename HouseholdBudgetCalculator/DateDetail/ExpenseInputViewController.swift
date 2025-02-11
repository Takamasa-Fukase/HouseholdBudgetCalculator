//
//  ExpenseInputViewController.swift
//  TravelBudgetCalculator
//
//  Created by ウルトラ深瀬 on 31/8/24.
//

import UIKit

class ExpenseInputViewController: UIViewController {
    var activeTextField: UIView?
    var monthlyExpense: MonthlyExpense = .init(
        title: "",
        expenseGroups: []
    )

    @IBOutlet weak var tableView: TouchesBeganTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // データがまだ存在しない場合は追加
        if UserDefaults.monthlyExpenses.isEmpty {
            UserDefaults.monthlyExpenses = [
                .init(
                    title: "2025年2月",
                    expenseGroups: [
                        .init(title: "スーパー", items: [
                            .init(title: "", amount: 0)
                        ]),
                        .init(title: "1人外食", items: [
                            .init(title: "", amount: 0)
                        ]),
                        .init(title: "コンビニ・自販機", items: [
                            .init(title: "", amount: 0)
                        ]),
                        .init(title: "カラオケ", items: [
                            .init(title: "", amount: 0)
                        ]),
                        .init(title: "1人カフェ", items: [
                            .init(title: "", amount: 0)
                        ]),
                        .init(title: "友達との交際費", items: [
                            .init(title: "", amount: 0)
                        ])
                    ]
                )
            ]
        }
        
        // 取り出したデータを格納
        monthlyExpense = UserDefaults.monthlyExpenses[0]
        
        setupTableView()
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: ExpenseInputCell.className, bundle: nil), forCellReuseIdentifier: ExpenseInputCell.className)
        tableView.register(UINib(nibName: ExpenseInputSectionHeader.className, bundle: nil), forHeaderFooterViewReuseIdentifier: ExpenseInputSectionHeader.className)
        tableView.register(UINib(nibName: ExpenseInputSectionFooter.className, bundle: nil), forHeaderFooterViewReuseIdentifier: ExpenseInputSectionFooter.className)
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInset.bottom = 200
    }

    // この画面の変数で保持しているデータをUserDefaultsに保存する
    func saveToUserDefaults() {
        var editedData = UserDefaults.monthlyExpenses
        let index = editedData.firstIndex(where: { $0.id == monthlyExpense.id }) ?? 0
        editedData[index] = monthlyExpense
        UserDefaults.monthlyExpenses = editedData
    }
}

extension ExpenseInputViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExpenseInputSectionHeader.className) as! ExpenseInputSectionHeader
        let sectionData = monthlyExpense.expenseGroups[section]
        var sumAmount: Int = 0
        sectionData.items.forEach({ item in
            sumAmount += item.amount
        })
        sectionHeader.expenseTypeLabel.text = "\(sectionData.title)：\(sumAmount)円"
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionFooter = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExpenseInputSectionFooter.className) as! ExpenseInputSectionFooter
        sectionFooter.formAddButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            let newItem = ExpenseItem(title: "", amount: 0)
            self.monthlyExpense.expenseGroups[section].items.append(newItem)
            
            self.saveToUserDefaults()
            
            self.tableView.reloadSections(IndexSet(integer: section), with: .none)
        }, for: .touchUpInside)
        return sectionFooter
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return monthlyExpense.expenseGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthlyExpense.expenseGroups[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseInputCell.className, for: indexPath) as! ExpenseInputCell
        let item = monthlyExpense.expenseGroups[indexPath.section].items[indexPath.row]
        
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
        
        cell.menuButton.addAction(UIAction { [weak self] _ in
            guard let self = self else {return}
            let id = cell.id
            guard let selectedItem = self.monthlyExpense.expenseGroups.first(where: { $0.items.contains(where: { $0.id == id }) })?.items.first(where: { $0.id == id }) else {
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
                let sectionIndex = self.monthlyExpense.expenseGroups.firstIndex(where: { section in
                    section.items.contains(where: { $0.id == id })
                }) ?? 0
                let rowIndex = self.monthlyExpense.expenseGroups[sectionIndex].items.firstIndex(where: { $0.id == id }) ?? 0
                let selectedIndexPath = IndexPath(row: rowIndex, section: sectionIndex)
                // 該当のデータを削除して画面を更新
                self.monthlyExpense.expenseGroups[selectedIndexPath.section].items.remove(at: selectedIndexPath.row)
                
                self.saveToUserDefaults()
                
                // セクションヘッダーに表示してる金額も更新したいので、
                // 単体でのdeleteRowsではなくsectionを丸ごと更新している
                self.tableView.reloadSections([indexPath.section], with: .automatic)
            }
            alert.addAction(cancel)
            alert.addAction(delete)
            self.present(alert, animated: true)
        }, for: .touchUpInside)
        
        cell.titleTextField.addAction(UIAction { [weak self] _ in
            guard let self = self else {return}
            let title = cell.titleTextField.text ?? ""
            self.monthlyExpense.expenseGroups[indexPath.section].items[indexPath.row].title = title
            
            self.saveToUserDefaults()
            
            /*
             項目名の入力後に完了をおさずにそのまま金額のフォームに移動するときにも更新してしまうと、金額のフォームのカーソルが消えてしまうバグがあるので、このタイミングでは更新しない。データソース自体は書き換えているので問題ないと思われる。
             */
//                self.tableView.reloadRows(at: [indexPath], with: .none)
        }, for: .editingDidEnd)
        
        cell.amountTextField.addAction(UIAction { [weak self] _ in
            guard let self = self else {return}
            self.monthlyExpense.expenseGroups[indexPath.section].items[indexPath.row].title = cell.titleTextField.text ?? ""
            self.monthlyExpense.expenseGroups[indexPath.section].items[indexPath.row].amount = Int(cell.amountTextField.text ?? "0") ?? 0
            
            self.saveToUserDefaults()
            
            // MEMO: セクションヘッダーに合計金額を表示しているため、セルだけでなくセクションを丸ごと更新している
            self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
        }, for: .editingDidEnd)
        
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

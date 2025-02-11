//
//  DateDetailViewController.swift
//  TravelBudgetCalculator
//
//  Created by ウルトラ深瀬 on 31/8/24.
//

import UIKit
import RxSwift
import RxCocoa

class DateDetailViewController: UIViewController {
    let disposeBag = DisposeBag()
    var activeTextField = BehaviorRelay<UIView?>(value: nil)
    var dailyExpense: DailyExpense = .init(id: UUID(), date: "", cityName: "", currency: .USD, expenseData: [])
    var travelId: UUID = UUID()
    var dateIndex: Int = 0
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var tableView: TouchesBeganTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.text = dailyExpense.date
        cityNameLabel.text = dailyExpense.cityName
        setupTableView()
        setRxKeyboardMovement(disposeBag: disposeBag,
                              scrollView: tableView,
                              textField: activeTextField.asObservable(),
                              view: view,
                              buttonConstraint: NSLayoutConstraint())
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: "PaymentListItemCell", bundle: nil), forCellReuseIdentifier: "PaymentListItemCell")
        tableView.register(UINib(nibName: "DateDetailGenreSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "DateDetailGenreSectionHeader")
        tableView.register(UINib(nibName: "DateDetailGenreSectionFooter", bundle: nil), forHeaderFooterViewReuseIdentifier: "DateDetailGenreSectionFooter")
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInset.bottom = 200
    }
    
    func yenAmountText(amount: Double, toYenRate: Double) -> String {
        let yenAmount = amount * toYenRate
        return "\(String(format: "%.0f", ceil(yenAmount)))円"
    }

    // この画面の変数で保持している1日の出費データをUserDefaultsに保存する
    func saveToUserDefaults() {
        var editedData = UserDefaults.travels
        let index = editedData.firstIndex(where: { $0.id == travelId }) ?? 0
        editedData[index].dateList[dateIndex] = dailyExpense
        UserDefaults.travels = editedData
    }
}

extension DateDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DateDetailGenreSectionHeader") as! DateDetailGenreSectionHeader
        let sectionData = dailyExpense.expenseData[section]
        let genreName = sectionData.paymentType.rawValue
        var sumAmount: Double = 0.0
        sectionData.items.forEach({ item in
            sumAmount += item.amount
        })
        // MEMO: 後でitemごとに個別のレートに変更できる機能を作る場合は、合計をitemごとのレートで先に計算してから合算するように修正が必要
        sectionHeader.genreLabel.text = "\(genreName)：\(yenAmountText(amount: sumAmount, toYenRate: dailyExpense.currency.toYenRate))"
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionFooter = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DateDetailGenreSectionFooter") as! DateDetailGenreSectionFooter
        sectionFooter.addFormButtonTapped = { [weak self] in
            guard let self = self else { return }
            let newItem = PaymentListItem(id: UUID(), title: "", amount: 0, currencyType: self.dailyExpense.currency)
            self.dailyExpense.expenseData[section].items.append(newItem)
            
            self.saveToUserDefaults()
            
            self.tableView.reloadSections(IndexSet(integer: section), with: .none)
        }
        return sectionFooter
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dailyExpense.expenseData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyExpense.expenseData[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentListItemCell", for: indexPath) as! PaymentListItemCell
        let item = dailyExpense.expenseData[indexPath.section].items[indexPath.row]
        
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
        // MARK: ここでは日付データが持っている共通通貨ではなく、item単体で保持されている通貨を使用する。
        // 今後、個別のセルの通貨を編集して保存する機能を作る予定があるので。（トルコでユーロを使ったみたいに。）
        cell.currencyLabel.text = "(\(item.currencyType.code))"
        cell.yenDisplayLabel.text = yenAmountText(amount: item.amount, toYenRate: item.currencyType.toYenRate)
        
        cell.menuButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else {return}
                let id = cell.id
                guard let selectedItem = self.dailyExpense.expenseData.first(where: { $0.items.contains(where: { $0.id == id }) })?.items.first(where: { $0.id == id }) else {
                    self.showError(message: "選択されたItemの取得に失敗")
                    return
                }
                let yenText = self.yenAmountText(amount: selectedItem.amount, toYenRate: selectedItem.currencyType.toYenRate)
                let message = "項目名：\(selectedItem.title)\n現地通貨：\(selectedItem.amount)\n（\(yenText)）"
                let alert = UIAlertController(
                    title: "項目を削除します",
                    message: message,
                    preferredStyle: .alert
                )
                let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
                let delete = UIAlertAction(title: "削除", style: .destructive) { _ in
                    let sectionIndex = self.dailyExpense.expenseData.firstIndex(where: { section in
                        section.items.contains(where: { $0.id == id })
                    }) ?? 0
                    let rowIndex = self.dailyExpense.expenseData[sectionIndex].items.firstIndex(where: { $0.id == id }) ?? 0
                    let selectedIndexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    // 該当のデータを削除して画面を更新
                    self.dailyExpense.expenseData[selectedIndexPath.section].items.remove(at: selectedIndexPath.row)
                    
                    self.saveToUserDefaults()
                    
                    // セクションヘッダーに表示してる金額も更新したいので、
                    // 単体でのdeleteRowsではなくsectionを丸ごと更新している
                    self.tableView.reloadSections([indexPath.section], with: .automatic)
                }
                alert.addAction(cancel)
                alert.addAction(delete)
                self.present(alert, animated: true)
            }).disposed(by: cell.disposeBag)
        
        cell.titleTextField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let self = self else {return}
                let title = cell.titleTextField.text ?? ""
                self.dailyExpense.expenseData[indexPath.section].items[indexPath.row].title = title
                
                self.saveToUserDefaults()
                
                /*
                 項目名の入力後に完了をおさずにそのまま金額のフォームに移動するときにも更新してしまうと、金額のフォームのカーソルが消えてしまうバグがあるので、このタイミングでは更新しない。データソース自体は書き換えているので問題ないと思われる。
                 */
//                self.tableView.reloadRows(at: [indexPath], with: .none)
            }).disposed(by: cell.disposeBag)
        
        cell.amountTextField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let self = self else {return}
                let title = cell.titleTextField.text ?? ""
                let doubleAmount = Double(cell.amountTextField.text ?? "") ?? 0.0
                self.dailyExpense.expenseData[indexPath.section].items[indexPath.row].title = title
                self.dailyExpense.expenseData[indexPath.section].items[indexPath.row].amount = doubleAmount
                
                self.saveToUserDefaults()
                
                // MEMO: セクションヘッダーに合計金額を表示しているため、セルだけでなくセクションを丸ごと更新している
                self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            }).disposed(by: cell.disposeBag)
        
        return cell
    }
}

extension DateDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField.accept(textField)
        return true
    }
}

//
//  MonthListViewController.swift
//  HouseholdBudgetCalculator
//
//  Created by ウルトラ深瀬 on 12/2/25.
//

import UIKit

class MonthListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    init() {
        super.init(nibName: MonthListViewController.className, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "月を選択"
        setupTableView()
        tableView.reloadData()
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        let vc = CommonMenuViewController(menuItems: [
            .init(title: "デフォルトテンプレートから作成", onSelected: { [weak self] in
                var textField = UITextField()
                let alert = UIAlertController(title: "タイトルを入力", message: "作成する支出入力データのタイトルを入力してください", preferredStyle: .alert)
                alert.addTextField { _textField in
                    textField = _textField
                    textField.returnKeyType = .done
                }
                alert.addAction(.init(title: "OK", style: .default) { _ in
                    self?.createMonthlyExpenseDataFromDefaultTemplate(title: textField.text ?? "")
                })
                alert.addAction(.init(title: "キャンセル", style: .cancel))
                self?.present(alert, animated: true)
            }),
            .init(title: "JSONファイルから作成", onSelected: { [weak self] in
                self?.showDocumentPickerVC()
            }),
        ])
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                .custom(resolver: { context in
                    return 200
                })]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: MonthListCell.className, bundle: .main), forCellReuseIdentifier: MonthListCell.className)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.top = 16
    }
    
    private func createMonthlyExpenseDataFromDefaultTemplate(title: String) {
        UserDefaults.monthlyExpenses += [
            .init(
                title: title,
                expenseGroups: [
                    .init(title: "スーパー",
                          budgetAmount: 25000,
                          items: [
                            .init(title: "", amount: 0)
                          ]),
                    .init(title: "1人外食",
                          budgetAmount: 3000,
                          items: [
                            .init(title: "", amount: 0)
                          ]),
                    .init(title: "コンビニ・自販機",
                          budgetAmount: 2000,
                          items: [
                            .init(title: "", amount: 0)
                          ]),
                    .init(title: "カラオケ",
                          budgetAmount: 3000,
                          items: [
                            .init(title: "", amount: 0)
                          ]),
                    .init(title: "1人カフェ",
                          budgetAmount: 10000,
                          items: [
                            .init(title: "", amount: 0)
                          ]),
                    .init(title: "友達との交際費",
                          budgetAmount: 30000,
                          items: [
                            .init(title: "", amount: 0)
                          ])
                ]
            )
        ]
        tableView.reloadData()
    }
    
    private func showDocumentPickerVC() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        documentPicker.delegate = self
        present(documentPicker, animated: true)
    }
}

extension MonthListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserDefaults.monthlyExpenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MonthListCell.className, for: indexPath) as! MonthListCell
        cell.dateLabel.text = UserDefaults.monthlyExpenses[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ExpenseGroupListViewController()
        vc.monthlyExpense = UserDefaults.monthlyExpenses[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            UserDefaults.monthlyExpenses.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension MonthListViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("didPick: \(urls)")
        guard let url = urls.first else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        do {
            let jsonData = try Data(contentsOf: url)
            let monthlyExpense = try JSONDecoder().decode(MonthlyExpense.self, from: jsonData)
            UserDefaults.monthlyExpenses += [monthlyExpense]
            tableView.reloadData()
            
        } catch {
            print("error: \(error)")
        }
        url.stopAccessingSecurityScopedResource()
    }
}

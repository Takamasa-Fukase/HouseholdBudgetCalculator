//
//  ExpenseGroupListViewController.swift
//  HouseholdBudgetCalculator
//
//  Created by ウルトラ深瀬 on 12/2/25.
//

import UIKit
import Parchment

class ExpenseGroupListViewController: UIViewController {
    var pagingViewController: PagingViewController!
    // TODO: initでDIしてletにしたい
    var monthlyExpense: MonthlyExpense = .init(title: "", expenseGroups: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        title = monthlyExpense.title
        view.backgroundColor = .systemBackground
        setupParchment()
        setNaviBarRightButton(systemImageName: "ellipsis.circle") { [weak self] in
            let vc = SettingsViewController(
                googleLoginSelected: {
                    
                },
                jsonDumpSelected: { [weak self] in
                    var textField = UITextField()
                    let alert = UIAlertController(title: "ファイル名を入力", message: "書き出すファイルの名前を入力してください", preferredStyle: .alert)
                    alert.addTextField { _textField in
                        _textField.text = self?.monthlyExpense.title
                        textField = _textField
                        textField.returnKeyType = .done
                    }
                    alert.addAction(.init(title: "OK", style: .default) { _ in
                        self?.shareJSONData(fileName: textField.text ?? "")
                    })
                    alert.addAction(.init(title: "キャンセル", style: .cancel))
                    self?.present(alert, animated: true)
                }
            )
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium()]
            }
            vc.modalPresentationStyle = .pageSheet
            self?.present(vc, animated: true)
        }
        setNaviBarRightButton(systemImageName: "calendar") {
            
        }
    }
    
    private func setupParchment() {
        let vcs = monthlyExpense.expenseGroups.map { expenseGroup in
            let vc = ExpenseInputViewController(
                // 各画面内でUserDefaultsに保存する時にidを使うので渡す
                monthlyExpenseId: monthlyExpense.id,
                expenseGroup: expenseGroup
            )
            vc.title = expenseGroup.title
            return vc
        }
        
        pagingViewController = .init(viewControllers: vcs)
        pagingViewController.textColor = .systemGray
        pagingViewController.selectedTextColor = .label
        pagingViewController.menuBackgroundColor = .systemBackground
        pagingViewController.font = .systemFont(ofSize: 14, weight: .medium)
        pagingViewController.selectedFont = .systemFont(ofSize: 14, weight: .medium)
        pagingViewController.indicatorOptions = .visible(height: 4, zIndex: .max - 1, spacing: .init(top: 0, left: 12, bottom: 0, right: 12), insets: .zero)
        
        // MARK: 一番入力済み項目の件数が多い（よく使う）グループを最初に表示する
        // まず金額が入力済みの項目があるグループだけにフィルタリング
        let nonEmptyExpenseGroups = monthlyExpense.expenseGroups.filter { $0.items.contains(where: { $0.amount > 0 }) }
        
        // それをitemsの件数が多い順にソートし、その1番目のグループを取得
        let mostUsedExpenseGroup = nonEmptyExpenseGroups.sorted(by: { $0.items.count > $1.items.count }).first

        // そのグループが元の配列の中で何番目にあるかを取得
        let mostUsedExpenseGroupIndex = monthlyExpense.expenseGroups.firstIndex(where: { $0.id == mostUsedExpenseGroup?.id }) ?? 0
        
        // 最初に表示するページを設定
        pagingViewController.select(index: mostUsedExpenseGroupIndex)
        
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pagingViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pagingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        pagingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pagingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func shareJSONData(fileName: String) {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let filePath = documentDirectory.appending(path: "\(fileName).json")
        
        do {
            let jsonData = try JSONEncoder().encode(monthlyExpense)
            try jsonData.write(to: filePath, options: .atomic)
            
        } catch {
            print("jsonData.write error: \(error)")
        }

        if fileManager.fileExists(atPath: filePath.path) {
            let activityVC = UIActivityViewController(activityItems: [filePath], applicationActivities: nil)
            present(activityVC, animated: true)
        }else {
            print("パスが存在しません: \(filePath)")
        }
    }
}

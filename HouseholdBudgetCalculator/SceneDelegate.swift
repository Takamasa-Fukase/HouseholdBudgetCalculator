//
//  SceneDelegate.swift
//  HouseholdBudgetCalculator
//
//  Created by ウルトラ深瀬 on 11/2/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let expenseInputVC = UIStoryboard(name: ExpenseInputViewController.className, bundle: nil).instantiateInitialViewController() as? ExpenseInputViewController
        window?.rootViewController = expenseInputVC
        window?.makeKeyAndVisible()
    }
}

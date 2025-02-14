//
//  UIViewController+Extension.swift
//  YoutubeViewer
//
//  Created by ウルトラ深瀬 on 27/10/24.
//

import UIKit

extension UIViewController {

    /* NavigationBar上の右側のアクションボタンを追加
     - ViewDidLoadで呼び出す。Storyboardは設定不要
     - ２つ横並びでボタンを設置する場合は右端に置きたいボタンから順番にそれぞれ別々で呼ぶ
     */
    func setNaviBarRightButton(systemImageName: String, onPressed: @escaping () -> Void) {
        let button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 40, height: 40))
        let image = UIImage(systemName: systemImageName)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        var buttonConfiguration = UIButton.Configuration.plain()
        buttonConfiguration.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        button.configuration = buttonConfiguration

        var rightBarButtonItems = navigationItem.rightBarButtonItems ?? []
        rightBarButtonItems.append(UIBarButtonItem(customView: button))
        navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: false)

        button.addAction(UIAction(handler: { _ in
            onPressed()
        }), for: .touchUpInside)
    }
}

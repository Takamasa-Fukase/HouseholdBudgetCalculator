//
//  NSObject+Extension.swift
//  YoutubeViewer
//
//  Created by ウルトラ深瀬 on 27/10/24.
//

import Foundation

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}

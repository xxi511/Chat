//
//  ViewEX.swift
//  G4HChat
//
//  Created by Codegreen on 27/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func roundCorner() {
        let radius = self.bounds.size.width / 2
        self.setCorner(radius: radius)
    }

    func setCorner(radius: CGFloat) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
    }

    func setBoardColor(hex: String, width: CGFloat=1.0) {
        self.layer.borderColor = UIColor(hex: hex).cgColor
        self.layer.borderWidth = width
    }
}

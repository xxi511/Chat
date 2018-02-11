//
//  UIImageEX.swift
//  G4HChat
//
//  Created by Codegreen on 10/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
import UIKit
extension UIImage {
    func base64Str() -> String? {
        guard let data = UIImagePNGRepresentation(self) else {
            return nil
        }
        return data.base64EncodedString()
    }
}

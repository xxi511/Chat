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

    func resizeIfNeed(size: CGSize) -> UIImage? {
        let appropriateSize = self.calMaxSize(size: size)
        return self.resizedImage(newSize: appropriateSize)
    }

    func calMaxSize(size: CGSize) -> CGSize {
        let maxH = size.height
        let maxW = size.width
        let factor = self.size.width / self.size.height
        var w: CGFloat = 0
        var h: CGFloat = 0
        if self.size.height <= maxH && self.size.width <= maxW {
            w = self.size.width
            h = self.size.height
        } else if self.size.height < self.size.width {
            w = maxW
            h = maxW / factor
        } else {
            h = maxH
            w = factor * maxH
        }
        return CGSize(width: w, height: h)
    }

    func resizedImage(newSize: CGSize) -> UIImage? {
        // Guard newSize is different
        guard self.size != newSize else { return self }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0,
                             width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

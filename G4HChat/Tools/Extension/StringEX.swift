//
//  StringEX.swift
//  G4HChat
//
//  Created by Codegreen on 20/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func deviceID() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "NoDeviceID"
    }

    func base64() -> String? {
        guard let strData = self.data(using: .utf8) else {
            return nil
        }
        return strData.base64EncodedString()
    }

    func iSODate()-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        var format = "yyyy-MM-dd'T'HH:mm:ss"
        let end = max(self.count - 21, 0)
        for i in 0..<end {
            if i == 0 {
                format.append(".")
            }
            format.append("S")
        }
        format.append("'Z'")
        dateFormatter.dateFormat = format
        return dateFormatter.date(from:self)!
    }

    func base64Image() -> UIImage? {
        guard let imgData = Data(base64Encoded: self) else {
            return nil
        }

        guard let img = UIImage(data: imgData) else {
            return nil
        }

        return img
    }
}

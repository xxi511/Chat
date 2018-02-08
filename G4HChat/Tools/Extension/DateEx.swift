//
//  DateEx.swift
//  G4HChat
//
//  Created by 陳建佑 on 05/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
extension Date {
    func toStr(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

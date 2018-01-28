//
//  HiModel.swift
//  G4HChat
//
//  Created by Codegreen on 20/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
struct HiModel: Codable {
    var hi = HiContent()
}

struct HiContent: Codable {
    var id: String = NSUUID().uuidString
    var ver: String = "0.14"
    var ua: String = "iOSChat/0.01 (MacIntel) Swift/4.0"
    var dev: String = "".deviceID()
    var lang: String = "EN"
}

//
//  Configure.swift
//  G4HChat
//
//  Created by Codegreen on 19/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
class Configure {
    // 10.144.39.75
    // 51.15.211.33
    static let baseURL = "ws://51.15.211.33:6060/v0/channels?"
    static let apikey = "AQEAAAABAAD_rAp4DJh05a1HAwFT3A6K"
    static let socketURL = "\(Configure.baseURL)apikey=\(Configure.apikey)"
}

// Hex Color
extension Configure {
    static let offlineGray = "c0c0c0" // user offline
    static let onlineGreen = "00b852" // user online
    static let incomingColor = "f1f0f0" // message incoming
    static let outgoingColor =  "4279ff"// messge outgoing
    static let lightGray = "f6f8fa" // messge bar bgcolor
}

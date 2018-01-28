//
//  CtrlModel.swift
//  G4HChat
//
//  Created by Codegreen on 20/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
struct CtrlModel: Codable {
    var ctrl: CtrlContent
}

struct CtrlContent: Codable {
    var id: String // Message Unique ID
    var code: Int // Status
    var text: String
    var topic: String? // subscribe topic
    var ts: String // Time
    // example format "2015-10-06T18:07:29.841Z"

    var params: ParamModel?
}

struct ParamModel: Codable {
    var build: String?
    var ver: String? // Version of the wire protocol
    var expires: String? // Login expires date
    var token: String?
    var user: String?
    var acs: ACSModel?
}

struct ACSModel: Codable {
    // Access Control Information
    // check detail: https://github.com/tinode/chat/blob/master/API.md#access-control
    var given: String
    var mode: String
    var want: String
}

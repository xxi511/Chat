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
    var ts: Date // Time
    var params: ParamModel?

    private enum CodingKeys: String, CodingKey {
        case id, code, text, topic, ts, params
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try! container.decode(String.self, forKey: .id)
        self.code = try! container.decode(Int.self, forKey: .code)
        self.text = try! container.decode(String.self, forKey: .text)
        self.topic = try? container.decode(String.self, forKey: .topic)
        let tsStr = try! container.decode(String.self, forKey: .ts)
        self.ts = tsStr.iSODate()
        self.params = try container.decodeIfPresent(ParamModel.self, forKey: .params)
    }
}

struct ParamModel: Codable {
    var build: String?
    var ver: String? // Version of the wire protocol
    var expires: String? // Login expires date
    var token: String?
    var user: String?
    var acs: ACSModel?
    var what: String?
}

struct ACSModel: Codable {
    // Access Control Information
    // check detail: https://github.com/tinode/chat/blob/master/API.md#access-control
    var given: String?
    var mode: String?
    var want: String?
}

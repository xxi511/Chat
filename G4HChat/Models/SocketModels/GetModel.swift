//
//  GetModel.swift
//  G4HChat
//
//  Created by Codegreen on 04/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
enum WhatEnum: String {
    case data = "data"
    case sub = "sub"
    case desc = "desc"
    case read = "read"
    case recv = "recv"
}

struct GetModel: Codable {
    var get: GetContent
    public init(topic: String, what: [WhatEnum],
                before: Int, limit: Int=24) {
        self.get = GetContent(topic: topic, what: what,
                              before: before, limit: limit)
    }
}

struct GetContent: Codable {
    var id: String
    var topic: String
    var what: String
    var data: GetDataModel
    public init(topic: String, what: [WhatEnum],
                before: Int, limit: Int=24) {
        self.id = UUID().uuidString
        self.topic = topic
        let whatRaw = what.flatMap { (what) -> String? in
            return what.rawValue
        }
        self.what = whatRaw.joined(separator: " ")
        self.data = GetDataModel(before: before, limit: limit)
    }
}

struct GetDataModel: Codable {
    var before: Int
    var limit: Int
    public init(before: Int, limit: Int=24) {
        self.before = before
        self.limit = limit
    }
}

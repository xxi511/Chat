//
//  DataModel.swift
//  G4HChat
//
//  Created by 陳建佑 on 01/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
struct DataModel: Codable {
    var data: DataVarModel
}

struct DataVarModel: Codable {
    var content: DataContentModel
    var from: String
    var seq: Int
    var topic: String
    var ts: Date

    private enum CodingKeys: String, CodingKey {
        case content, from, seq, topic, ts
    }

    public init(from decoder: Decoder) throws {
        let json = try decoder.container(keyedBy: CodingKeys.self)
        self.content = try! json.decode(DataContentModel.self, forKey: .content)
        self.from = try! json.decode(String.self, forKey: .from)
        self.seq = try! json.decode(Int.self, forKey: .seq)
        self.topic = try! json.decode(String.self, forKey: .topic)
        let tsStr = try! json.decode(String.self, forKey: .ts)
        self.ts = tsStr.iSODate()
    }
}

struct DataContentModel: Codable {
    var ent: [DataEntModel]?
    var fmt: [DataFmtModel]?
}

struct DataEntModel: Codable {
    var data: EntDataModel
    var tp: String
}

struct EntDataModel: Codable {
    var mime: String
    var name: String
    var val: String
    var height: Int?
    var width: Int?
}

struct DataFmtModel: Codable {
    var at: Int?
    var len: Int?
}

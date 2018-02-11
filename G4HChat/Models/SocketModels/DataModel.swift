//
//  DataModel.swift
//  G4HChat
//
//  Created by 陳建佑 on 01/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
import UIKit

struct DataModel: Codable {
    var data: DataVarModel
}

struct DataVarModel: Codable {
    enum messageType {
        case text
        case image
        case UnKnow
    }
    var content: DataContentModel
    var from: String
    var seq: Int
    var topic: String
    var ts: Date
    var messageType: messageType

    private enum CodingKeys: String, CodingKey {
        case content, from, seq, topic, ts
    }

    public init(from decoder: Decoder) throws {
        let json = try decoder.container(keyedBy: CodingKeys.self)
        if let contentStr = try? json.decode(String.self, forKey: .content) {
            self.content = DataContentModel(txt: contentStr)
            self.messageType = .text
        } else {
            self.content = try! json.decode(DataContentModel.self, forKey: .content)
            self.messageType = DataVarModel.getMessageType(content: self.content)
        }
        self.from = try! json.decode(String.self, forKey: .from)
        self.seq = try! json.decode(Int.self, forKey: .seq)
        self.topic = try! json.decode(String.self, forKey: .topic)
        let tsStr = try! json.decode(String.self, forKey: .ts)
        self.ts = tsStr.iSODate()
    }

    static private func getMessageType(content: DataContentModel) -> messageType {
        guard let mime = content.ent![0].data.mime else {
            return .text
        }
        if mime.contains("image") {
            return .image
        } else {
            return .UnKnow
        }
    }
}

struct DataContentModel: Codable {
    var ent: [DataEntModel]?
    var fmt: [DataFmtModel]?
    var txt: String?

    public init(txt: String) {
        self.txt = txt
    }

    public init(base64Img: String, size: CGSize, name: String?=nil) {
        let data = EntDataModel(base64Img: base64Img,
                                   size: size, name: name)
        let entData = DataEntModel(data: data, tp: "IM")
        let fmtData = DataFmtModel(at: nil, len: 1, key: nil)
        self.ent = [entData]
        self.fmt = [fmtData]
        self.txt = " "
    }
}

struct DataEntModel: Codable {
    var data: EntDataModel
    var tp: String

}

struct EntDataModel: Codable {
    var mime: String?
    var name: String?
    var val: String?
    var height: CGFloat?
    var width: CGFloat?
    var url: String?

    public init(base64Img: String, size: CGSize, name: String?=nil) {
        self.mime = "image/png"
        self.name = (name == nil) ? UUID().uuidString: name
        self.val = base64Img
        self.height = size.height
        self.width = size.width
    }
}

struct DataFmtModel: Codable {
    var at: Int?
    var len: Int?
    var key: Int?
}

//
//  MetaModel.swift
//  G4HChat
//
//  Created by Codegreen on 27/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
struct MetaModel: Codable {
    var meta: MetaContent
}

struct MetaContent: Codable {
    var id: String
    var topic: String
    var ts: Date
    var desc: DescModel?
    var sub: [MetaInfo]?

    private enum CodingKeys: String, CodingKey {
        case id, topic, ts, desc, sub
    }

    public init(from decoder: Decoder) throws {
        let json = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try! json.decode(String.self, forKey: .id)
        self.topic = try! json.decode(String.self, forKey: .topic)
        let tsStr = try! json.decode(String.self, forKey: .ts)
        self.ts = tsStr.iSODate()
        self.desc = try json.decodeIfPresent(DescModel.self, forKey: .desc)
        self.sub = try json.decodeIfPresent([MetaInfo].self, forKey: .sub)
    }
}

struct DescModel: Codable {
    var privateStr: String?
    var defacs: DefacsModel?
    var publicInfo: PublicModel

    private enum CodingKeys: String, CodingKey {
        case privateStr = "private"
        case defacs
        case publicInfo = "public"
    }
}

struct DefacsModel: Codable {
    var auth: String
    var anon: String
}

struct PublicModel: Codable {
    var fn: String
    var photo: PhotoModel?
}

struct PhotoModel: Codable {
    var imgData: String
    var type: String

    private enum CodingKeys: String, CodingKey {
        case imgData = "data"
        case type
    }
}

struct MetaInfo: Codable {
    var acs: ACSModel
    var privateStr: String?
    var publicInfo: PublicModel
    var read: Int?
    var recv: Int?
    var seq: Int?
    var topic: String?
    var updated: Date
    var online: Bool?
    var user: String?

    private enum CodingKeys: String, CodingKey {
        case acs
        case privateStr = "private"
        case publicInfo = "public"
        case read, recv, seq, topic, updated, online, user
    }

    public init(from decoder: Decoder) throws {
        let json = try decoder.container(keyedBy: CodingKeys.self)
        self.acs = try! json.decode(ACSModel.self, forKey: .acs)
        self.privateStr = try json.decodeIfPresent(String.self, forKey: .privateStr)
        self.publicInfo = try! json.decode(PublicModel.self, forKey: .publicInfo)
        self.read = try? json.decode(Int.self, forKey: .read)
        self.recv = try? json.decode(Int.self, forKey: .recv)
        self.seq = try? json.decode(Int.self, forKey: .seq)
        self.topic = try? json.decode(String.self, forKey: .topic)
        let tsStr = try! json.decode(String.self, forKey: .updated)
        self.updated = tsStr.iSODate()
        self.online = try? json.decode(Bool.self, forKey: .online)
        self.user = try? json.decode(String.self, forKey: .user)
    }
}


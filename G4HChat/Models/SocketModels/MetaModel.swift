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
    var ts: String
    var desc: DescModel?
    var sub: [ChatInfo]?
}

struct DescModel: Codable {
    var privateStr: String
    var defacs: DefacsModel
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

struct ChatInfo: Codable {
    var acs: ACSModel
    var privateStr: String?
    var publicInfo: PublicModel
    var read: Int?
    var recv: Int?
    var seq: Int?
    var topic: String
    var updated: String
    var online: Bool?

    private enum CodingKeys: String, CodingKey {
        case acs
        case privateStr = "private"
        case publicInfo = "public"
        case read
        case recv
        case seq
        case topic
        case updated
        case online
    }
}


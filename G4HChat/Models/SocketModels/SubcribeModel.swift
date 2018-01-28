//
//  SubcribeModel.swift
//  G4HChat
//
//  Created by Codegreen on 27/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
struct SubcribeModel: Codable {
    var sub: SubcribeContent

    init(topic: String, what: String) {
        self.sub = SubcribeContent(topic: topic, what: what)
    }
}

struct SubcribeContent: Codable {
    var id: String
    var topic: String
    var get: SubGetModel

    init(topic: String, what: String) {
        self.id = UUID().uuidString
        self.topic = topic
        self.get = SubGetModel(what: what)
    }
}

struct SubGetModel: Codable {
    var what: String

}

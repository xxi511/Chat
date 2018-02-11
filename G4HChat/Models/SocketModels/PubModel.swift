//
//  PubModel.swift
//  G4HChat
//
//  Created by Codegreen on 10/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
struct PubModel<T: Codable>: Codable {
    var pub: PubContent<T>
    public init(topic: String, content: T) {
        self.pub = PubContent(topic: topic, content: content)
    }
}

struct PubContent<T: Codable>: Codable {
    var content: T
    var id: String
    var topic: String
    public init(topic: String, content: T) {
        self.id = UUID().uuidString
        self.topic = topic
        self.content = content
    }
}

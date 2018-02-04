//
//  LeaveModel.swift
//  G4HChat
//
//  Created by Codegreen on 03/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
struct LeaveModel: Codable {
    var leave: LeaveContent
    public init(topic: String) {
        self.leave = LeaveContent(topic: topic)
    }
}

struct LeaveContent: Codable {
    var id: String
    var topic: String
    public init(topic: String) {
        self.id = UUID().uuidString
        self.topic = topic
    }
}

//
//  NoteModel.swift
//  G4HChat
//
//  Created by 陳建佑 on 12/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
struct NoteModel: Codable {
    var note: NoteContent
    public init(topic: String, what: WhatEnum,
                seq: Int?=nil) {
        self.note = NoteContent(topic: topic,
                                what: what.rawValue,
                                seq: seq)
    }
}

struct NoteContent: Codable {
    var topic: String
    var what: String
    var seq: Int?
}

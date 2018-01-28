//
//  PresModel.swift
//  G4HChat
//
//  Created by Codegreen on 28/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
struct PresModel: Codable {
    var pres: PresContent
}

struct PresContent: Codable {
    var topic: String
    var src: String
    var what: String
}

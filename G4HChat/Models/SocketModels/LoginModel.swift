//
//  LoginModel.swift
//  G4HChat
//
//  Created by Codegreen on 20/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
struct LoginModel: Codable {
    var login: LoginContent

    init(secret: String) {
        self.login = LoginContent(secret: secret)
    }
}

struct LoginContent: Codable {
    var id: String
    var scheme: String
    var secret: String

    init(secret: String) {
        self.id = UUID().uuidString
        self.secret = secret
        self.scheme = "basic"
    }
}

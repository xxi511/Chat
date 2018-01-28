//
//  UserModel.swift
//  G4HChat
//
//  Created by Codegreen on 27/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
import UIKit

struct UserModel {
    var expires: Date
    var token: String
    var user: String
    var name: String = ""
    var photo: UIImage?

    init(expires: Date, token: String, user: String) {
        self.expires = expires
        self.token = token
        self.user = user
    }
}

//
//  WebSocketProtocol.swift
//  G4HChat
//
//  Created by Codegreen on 27/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
protocol WebSocketProtocol {

    // MARK: Optional
    func loginResult(user: UserModel?, error: String?)
    func subcribeMeResult(chatList: [ChatInfo]?, error: String?)
}

extension WebSocketProtocol {
    func loginResult(user: UserModel?, error: String?) {}
    func subcribeMeResult(chatList: [ChatInfo]?, error: String?) {}
}

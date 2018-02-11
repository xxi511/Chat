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

    func subcribeTopic(_ topic: String, error: String)
    func subcribeTopic(_ topic: String, ctrl: CtrlContent)
    func subcribeTopic(_ topic: String, metaInfo: [MetaInfo])
    func subcribeTopic(_ topic: String, desc: DescModel)
    func subcribeData(_ data: DataVarModel)

    func pubData(_ topic: String, error: String)
}

extension WebSocketProtocol {
    func loginResult(user: UserModel?, error: String?) {}

    func subcribeTopic(_ topic: String, ctrl: CtrlContent) {}
    func subcribeTopic(_ topic: String, error: String) {}
    func subcribeTopic(_ topic: String, metaInfo: [MetaInfo]) {}
    func subcribeTopic(_ topic: String, desc: DescModel) {}
    func subcribeData(_ data: DataVarModel) {}

    func pubData(_ topic: String, error: String) {}
}

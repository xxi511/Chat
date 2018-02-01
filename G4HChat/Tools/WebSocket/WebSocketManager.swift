//
//  WebSocketManager.swift
//  G4HChat
//
//  Created by Codegreen on 19/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
import UIKit
import Starscream

class WebSocketManager {

    enum MessageType {
        case Hi
        case Login
        case SubTopic
    }

    static let shard = WebSocketManager()
    private let ws: WebSocket
    private var msgRecord: [String: MessageType]
    private(set) var saidHi: Bool = false
    private(set) var currentUser: UserModel?
    var delegate: WebSocketProtocol?

    init() {
        self.msgRecord = [:]
        self.ws = WebSocket(url: URL(string: Configure.socketURL)!)
        self.ws.advancedDelegate = self
    }

    func open() {
        self.ws.connect()
    }

    func send(message: Data) {
        self.ws.write(data: message)
    }

    func login(account: String, password: String) {
        let secret = "\(account):\(password)"
        let login = LoginModel(secret: secret.base64()!)
        let data = try! JSONEncoder().encode(login)
        self.msgRecord[login.login.id] = .Login
        self.ws.write(data: data)
    }

    func subcribeMe() {
        let subModel = SubcribeModel(topic: "me", what: "sub desc")
        let data = try! JSONEncoder().encode(subModel)
        self.msgRecord[subModel.sub.id] = .SubTopic
        self.ws.write(data: data)
    }

    func subcribeRoom(topic: String, limit: Int=24) {
        let data = SubDataModel(limit: limit)
        let sub = SubcribeModel(topic: topic, what: "data sub desc", data: data)
        let jsonData = try! JSONEncoder().encode(sub)
        self.msgRecord[sub.sub.id] = .SubTopic
        self.ws.write(data: jsonData)
    }
}

// MARK: echo
extension WebSocketManager: WebSocketAdvancedDelegate {
    func websocketDidConnect(socket: WebSocket) {
        print("WebSocket Open")
        self.sayHi()
    }

    func websocketDidDisconnect(socket: WebSocket, error: Error?) {
        print("WebSocket disconnect")
    }

    func websocketDidReceiveMessage(socket: WebSocket, text: String, response: WebSocket.WSResponse) {

        let data = text.data(using: .utf8)!
        if text.hasPrefix("{\"ctrl\"") {
            let ctrlModel = try! JSONDecoder().decode(CtrlModel.self, from: data)
            self.handleCtrl(res: ctrlModel)
        } else if text.hasPrefix("{\"meta\"") {
            let metaModel = try! JSONDecoder().decode(MetaModel.self, from: data)
            self.handleMeta(meta: metaModel)
        } else if text.hasPrefix("{\"pres\"") {
            let presModel = try! JSONDecoder().decode(PresModel.self, from: data)
            self.handlePres(res: presModel)
        } else if text.hasPrefix("{\"data\"") {
            let dataModel = try! JSONDecoder().decode(DataModel.self, from: data)
            self.delegate?.subcribeData(dataModel.data)
        }
    }


    func websocketDidReceiveData(socket: WebSocket, data: Data, response: WebSocket.WSResponse) {
        print("Websocket receive data")
    }

    func websocketHttpUpgrade(socket: WebSocket, request: String) {
        print("Websocket upgrade by request")
    }

    func websocketHttpUpgrade(socket: WebSocket, response: String) {
        print("Websocket upgrade by response")
    }
}

// MARK: Handle Func
extension WebSocketManager {

    private func handleCtrl(res: CtrlModel) {
        guard let type = self.msgRecord[res.ctrl.id] else {
            return
        }

        switch type {
        case .Hi:
            print("Get Hi Response")
            self.saidHi = true
            self.msgRecord.removeValue(forKey: res.ctrl.id)
        case .Login:
            print("Get Login Response")
            self.msgRecord.removeValue(forKey: res.ctrl.id)
            self.handleLogin(res: res)
        case .SubTopic:
            print("Get Subcribe Room Ctrl")
            self.handleSubcribeTopic(res: res, meta: nil)
        }
    }

    private func handleMeta(meta: MetaModel) {
        guard let type = self.msgRecord[meta.meta.id] else {
            return
        }
        switch type {
        case .SubTopic:
            print("Get Subcribe Topic")
            self.handleSubcribeTopic(res: nil, meta: meta)
        default: return
        }
    }

    private func handlePres(res: PresModel) {
        if res.pres.topic == "me" {
            self.setChatRoomStatus(res: res)
        }
    }

    private func handleLogin(res: CtrlModel) {
        guard res.ctrl.code == 200 else {
            self.delegate?.loginResult(user: nil,
                                       error: res.ctrl.text)
            return
        }
        let expire = res.ctrl.params!.expires!
        let token = res.ctrl.params!.token!
        let user = res.ctrl.params!.user!
        self.currentUser = UserModel(expires: expire.iSODate(),
                                     token: token, user: user)
        self.delegate?.loginResult(user: self.currentUser,
                                   error: nil)
    }

    private func handleSubcribeTopic(res: CtrlModel?, meta: MetaModel?) {
        
        if let res = res {
            let topic = res.ctrl.topic!
            guard res.ctrl.code == 200 else {
                let err = res.ctrl.text
                self.delegate?.subcribeTopic(topic, error: err)
                return
            }
            self.delegate?.subcribeTopic(topic, ctrl: res.ctrl)
        } else if let meta = meta {
            let topic = meta.meta.topic
            if meta.meta.desc != nil {
                self.handleMetaDesc(topic, desc: meta.meta.desc!)
            } else if meta.meta.sub != nil {
                self.delegate?.subcribeTopic(topic, metaInfo: meta.meta.sub!)
                if meta.meta.topic == "me" {
                    self.msgRecord.removeValue(forKey: meta.meta.id)
                }
                // Does subcribe Topic only 3 frame
            }
        }
    }

    private func handleMetaDesc(_ topic: String, desc: DescModel) {
        if topic == "me" {
            self.setUserInfo(desc: desc)
        } else {
            self.delegate?.subcribeTopic(topic, desc: desc)
        }
    }
}

// MARK: Func
extension WebSocketManager {

    private func sayHi() {
        let hiModel = HiModel()
        self.msgRecord[hiModel.hi.id] = .Hi
        let hiData = try! JSONEncoder().encode(hiModel)
        self.send(message: hiData)
    }

    private func setUserInfo(desc: DescModel) {
        self.currentUser?.name = desc.publicInfo.fn
        let imgDataStr = desc.publicInfo.photo!.imgData
        self.currentUser?.photo = imgDataStr.base64Image()!
    }

    private func setChatRoomStatus(res: PresModel) {
        let topVC = UIApplication.topViewController()
        if let homeVC = topVC as? HomeVC {
            homeVC.setRoomStatus(src: res.pres.src, status: res.pres.what)
        } else {
            let arr = topVC?.navigationController?.viewControllers
            let homeVC = arr?.first {$0.isKind(of: HomeVC.self)} as? HomeVC
            homeVC?.setRoomStatus(src: res.pres.src, status: res.pres.what)
        }
    }
}

//
//  ChatVC.swift
//  G4HChat
//
//  Created by 陳建佑 on 01/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit

class ChatVC: UIViewController {

    private var topic: String = ""
    private let socket = WebSocketManager.shard
    private var isFirst = true
    private var members = [MetaInfo]()
    private var messages = [DataVarModel]()

    class func instance(_ topic: String) -> ChatVC {
        let board = UIStoryboard(name: "Chat", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.topic = topic
        vc.members.removeAll()
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.socket.delegate = self
        if self.isFirst {
            self.socket.subcribeRoom(topic: self.topic, limit: 24)
            self.isFirst = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            self.socket.leaveTopic(self.topic)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ChatVC: WebSocketProtocol {
    func subcribeTopic(_ topic: String, error: String) {
        guard topic == self.topic else {return}
        self.noticeAlert(title: "Error", message: error)
    }

    func subcribeTopic(_ topic: String, ctrl: CtrlContent) {
        guard topic == self.topic else {return}
        guard let what = ctrl.params?.what else {return}
        if what == "data" {
            self.socket.removeRecord(key: ctrl.id)
            // update view
            let k = self.messages
            print("data done")
        }
    }

    func subcribeTopic(_ topic: String, desc: DescModel) {
        guard topic == self.topic else {return}
        self.title = desc.publicInfo.fn
    }

    func subcribeTopic(_ topic: String, metaInfo: [MetaInfo]) {
        guard topic == self.topic else {return}
        self.members = metaInfo
    }

    func subcribeData(_ data: DataVarModel) {
        self.messages.append(data)
    }
}

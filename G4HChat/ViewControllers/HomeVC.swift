//
//  HomeVC.swift
//  G4HChat
//
//  Created by Codegreen on 27/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    @IBOutlet var tableView: UITableView!

    private let socket = WebSocketManager.shard
    private var roomList = [MetaInfo]()
    private var isFirst = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "CHAT"
        self.socket.delegate = self
        if self.isFirst {
            self.socket.subcribeMe()
            self.isFirst = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension HomeVC: WebSocketProtocol {
    func subcribeTopic(_ topic: String, error: String) {
        guard topic == "me" else {return}
        self.view.hideToastActivity()
        self.noticeAlert(title: "Error", message: error)
    }

    func subcribeTopic(_ topic: String, metaInfo: [MetaInfo]) {
        guard topic == "me" else {return}
        self.view.hideToastActivity()
        self.roomList = metaInfo
        self.tableView.reloadData()
    }
}

// MARK: UITableView
extension HomeVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.roomList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoom") as! ChatInfoCell
        let data = self.roomList[indexPath.row]
        if let photo = data.publicInfo.photo {
            cell.avatar.image = photo.imgData.base64Image()
        } 

        cell.titleLabel.text = data.publicInfo.fn
        cell.messageLabel.text = data.privateStr
        let seq = data.seq ?? 0
        let read = data.read ?? 0
        cell.unReadNum = seq - read
        cell.isOnline = data.online ?? false

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = self.roomList[indexPath.row]
        let vc = ChatVC.instance(data.topic!)
        self.navigationController?.show(vc, sender: self)
    }
}

// MARK: Funcs
extension HomeVC {
    private func viewInit() {
        self.view.makeToastActivity(.center)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        let nib = ChatInfoCell.nib()
        self.tableView.register(nib,
                                forCellReuseIdentifier: "ChatRoom")
    }

    func setRoomStatus(src: String, status: String) {
        let idx = self.roomList.index(where: {$0.topic == src})
        guard idx != nil else {return}
        self.roomList[idx!].online = (status == "ok") ? true: false

        let path = IndexPath(row: idx!, section: 0)
        self.tableView.reloadRows(at: [path], with: .fade)
    }
}

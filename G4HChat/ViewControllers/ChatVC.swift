//
//  ChatVC.swift
//  G4HChat
//
//  Created by 陳建佑 on 01/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit

class ChatVC: UIViewController {

    private let textCell = "textCell"
    private let imgCell = "imgCell"

    private var topic: String = ""
    private let socket = WebSocketManager.shard
    private var isFirst = true
    private var members = [MetaInfo]()
    private var messages = [DataVarModel]()

    @IBOutlet var chatTable: UITableView!
    @IBOutlet var messageView: UIView!
    @IBOutlet var messageViewBottom: NSLayoutConstraint!
    @IBOutlet var messageTextView: UITextView!
    @IBOutlet var sendBtn: UIButton!


    class func instance(_ topic: String) -> ChatVC {
        let board = UIStoryboard(name: "Chat", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.topic = topic
        vc.members.removeAll()
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewLayoutInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.socket.delegate = self
        if self.isFirst {
            self.view.makeToastActivity(.center)
            self.socket.subcribeRoom(topic: self.topic, limit: 24)
            self.isFirst = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(noti:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(noti:)), name: .UIKeyboardWillHide, object: nil)
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

    @IBAction func clickSendMsgBtn(_ sender: Any) {

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
            self.view.hideToastActivity()
            self.chatTable.reloadData()
            if self.messages.count > 0 {
                let path = IndexPath(row: self.messages.count-1, section: 0)
                self.chatTable.scrollToRow(at: path, at: .top, animated: false)
            }

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

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.messages[indexPath.row]
        switch data.messageType {
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: self.textCell) as! TextMsgCell
            self.setTextCell(cell, data: data)
            cell.layoutIfNeeded()
            return cell
        case .image:
            let cell = tableView.dequeueReusableCell(withIdentifier: self.imgCell) as! ImageMsgCell
            self.setImgCell(cell, data: data)
            cell.layoutIfNeeded()
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: self.textCell) as! TextMsgCell
            self.setTextCell(cell, data: data, isSupport: false)
            cell.layoutIfNeeded()
            return cell
        }
    }

    private func setTextCell(_ cell: TextMsgCell, data: DataVarModel,
                             isSupport: Bool=true) {
        if data.from == self.socket.currentUser!.user {
            cell.isIncoming = false
        } else {
            cell.isIncoming = true
            let (img, name) = self.getUserInfo(user: data.from)
            cell.avatar.image = img
            cell.name.text = name
        }

        cell.message.text = (isSupport) ? data.content.txt: "Not support message type"
        cell.timeLabel.text = data.ts.toStr(format: "HH:mm a")
    }

    private func setImgCell(_ cell: ImageMsgCell, data: DataVarModel) {
        if data.from == self.socket.currentUser!.user {
            cell.isIncoming = false
        } else {
            cell.isIncoming = true
            let (img, name) = self.getUserInfo(user: data.from)
            cell.avatar.image = img
            cell.name.text = name
        }
        let img = data.content.ent![0].data.val?.base64Image() ?? #imageLiteral(resourceName: "errorImage")
        cell.photo.image = img
        cell.setAppropriateSize(origin: img.size)
        cell.timeLabel.text = data.ts.toStr(format: "HH:mm a")
    }
}

// MARK: Notification
extension ChatVC {
    @objc private func keyboardWillShow(noti: Notification) {
        let info = noti.userInfo!
        let size = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
        self.setMessageBottom(height: size.height)
    }

    @objc private func keyboardWillHide(noti: Notification) {
        self.setMessageBottom(height: 0)
    }
}

// MARK: Layout
extension ChatVC {
    private func viewLayoutInit() {
        self.messageTextView.setCorner(radius: 5)
        self.messageTextView.setBoardColor(hex: "9a9a9a")

        self.chatTable.tableFooterView = UIView(frame: CGRect.zero)
        self.chatTable.estimatedRowHeight = 50
        self.chatTable.rowHeight = UITableViewAutomaticDimension

        let textNib = TextMsgCell.nib()
        self.chatTable.register(textNib,
                                forCellReuseIdentifier: self.textCell)
        let imgNib = ImageMsgCell.nib()
        self.chatTable.register(imgNib,
                                forCellReuseIdentifier: self.imgCell)
    }

    private func setMessageBottom(height: CGFloat) {
        UIView.animate(withDuration: 0.25) {
            self.messageViewBottom.constant = height
        }
    }
}

// MARK: Funcs
extension ChatVC {
    private func getUserInfo(user: String) -> (UIImage, String) {
        guard let member = self.members.first(where: {$0.user! == user}) else {
            return (#imageLiteral(resourceName: "avatar"), "Unknow")
        }
        guard let photo = member.publicInfo.photo else {
            return (#imageLiteral(resourceName: "avatar"), member.publicInfo.fn)
        }
        return (photo.imgData.base64Image() ?? #imageLiteral(resourceName: "avatar"), member.publicInfo.fn)
    }
}

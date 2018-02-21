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
    private enum UpdateStatus {
        case Init, Previus, Standby
    }

    private enum BottomMode {
        case Init, Photo, Keyboard
    }

    private var topic: String = ""
    private let socket = WebSocketManager.shard
    private var isFirst = true
    private var members = [MetaInfo]()
    private var messages = [DataVarModel]()
    private var received = [DataVarModel]()
    private var refresher = UIRefreshControl(frame: .zero)
    private var status: UpdateStatus = .Init

    @IBOutlet private var chatTable: UITableView!
    @IBOutlet private var messageView: UIView!
    @IBOutlet private var messageViewBottom: NSLayoutConstraint!
    @IBOutlet private var messageTextView: UITextView!
    @IBOutlet private var messageTextViewH: NSLayoutConstraint!
    @IBOutlet var messageTextViewL: NSLayoutConstraint!
    @IBOutlet private var sendBtn: UIButton!
    @IBOutlet var cameraBtn: UIButton!
    @IBOutlet var photoBtn: UIButton!
    @IBOutlet var photoView: UIView!
    

    class func instance(_ topic: String) -> ChatVC {
        let board = UIStoryboard(name: "Chat", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.topic = topic
        vc.members.removeAll()
        vc.received.removeAll()
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
        let txt = self.messageTextView.text
        guard txt != "" || txt != "Aa" else {return}
        self.socket.pubData(topic: self.topic, content: txt!)
        self.defaultText()
        self.messageTextView.endEditing(true)
    }

    @IBAction func clickCameraBtn(_ sender: Any) {
        self.setMessageBottom(height: 0, mode: .Init)
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            self.noticeAlert(title: "Error",
                             message: "Camera is not available", isPop: false)
            return
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = false
        self.present(picker, animated: true, completion: nil)
    }

    @IBAction func clickPhotoBtn(_ sender: UIButton) {
        self.messageTextView.endEditing(true)
        if sender.isSelected == false {
            sender.isSelected = true
            self.setMessageBottom(height: 240, mode: .Photo)
            self.preparePhotoVC()
        } else {
            sender.isSelected = false
            self.setMessageBottom(height: 0, mode: .Init)
        }
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
            self.chatTableReload()
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
        if self.status == .Standby {
            self.insertData(data)
        } else {
            self.received.append(data)
            print(self.received.count)
        }
    }
}

// MARK: UITableView
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
        cell.setAppropriateSize(origin: img.size)
        cell.photo.image = img
        cell.timeLabel.text = data.ts.toStr(format: "HH:mm a")
    }
}

// MARK: UITextView
extension ChatVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        self.messageTextViewL.constant = 60
        self.textViewDidChange(self.messageTextView)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if textView.text == "" || textView.text == "Aa" {
            self.defaultText()
        }
        self.messageTextViewL.constant = 105
        self.messageTextViewH.constant = 34
    }

    func textViewDidChange(_ textView: UITextView) {
        let size = textView.bounds.size
        let estimate = CGSize(width: size.width,
                              height: CGFloat.greatestFiniteMagnitude)
        let prefer = textView.sizeThatFits(estimate)
        let lineHeight = textView.font?.lineHeight ?? 17.9
        let max = lineHeight * 3
        if prefer.height <= 34 {
            self.messageTextViewH.constant = 34
            textView.isScrollEnabled = false
        } else if prefer.height > max {
            self.messageTextViewH.constant = max
            textView.isScrollEnabled = true
        } else {
            self.messageTextViewH.constant = prefer.height
            textView.isScrollEnabled = false
        }
    }
}

// MARK: UIImagePicker
extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let img = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }
        self.socket.pubData(topic: self.topic, content: img)
    }
}

// MARK: PhotoVC Delegate
extension ChatVC: PhotoVCDelegate {
    func photoPermissionDenied() {
        self.setMessageBottom(height: 0, mode: .Init)
    }

    func wantToSendImage(image: UIImage) {
        self.socket.pubData(topic: self.topic, content: image)
    }
}

// MARK: Notification
extension ChatVC {
    @objc private func keyboardWillShow(noti: Notification) {
        let info = noti.userInfo!
        let size = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
        self.setMessageBottom(height: size.height, mode: .Keyboard)
    }

    @objc private func keyboardWillHide(noti: Notification) {
        self.setMessageBottom(height: 0, mode: .Init)
    }
}

// MARK: Layout
extension ChatVC {
    private func viewLayoutInit() {
        self.messageTextView.setCorner(radius: 17)
        self.messageTextView.setBoardColor(hex: "9a9a9a")
        self.defaultText()

        self.tableviewSetting()
        }

    private func tableviewSetting() {
        self.chatTable.tableFooterView = UIView(frame: CGRect.zero)
        self.chatTable.estimatedRowHeight = 50
        self.chatTable.rowHeight = UITableViewAutomaticDimension

        let textNib = TextMsgCell.nib()
        self.chatTable.register(textNib,
                                forCellReuseIdentifier: self.textCell)
        let imgNib = ImageMsgCell.nib()
        self.chatTable.register(imgNib,
                                forCellReuseIdentifier: self.imgCell)

        self.refresher.addTarget(self, action: #selector(self.loadPreviusData), for: .valueChanged)
        self.chatTable.addSubview(self.refresher)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapScreen))
        self.chatTable.addGestureRecognizer(tap)
    }

    private func setMessageBottom(height: CGFloat,
                                  mode: BottomMode) {
        self.messageViewBottom.constant = height

        self.photoBtn.isHidden = false
        self.photoBtn.tintColor = UIColor.black
        switch mode {
        case .Init:
            self.photoBtn.isSelected = false
            self.messageTextViewL.constant = 105
        case .Keyboard:
            self.photoBtn.isSelected = false
            self.photoBtn.isHidden = true
            self.messageTextViewL.constant = 60
        case .Photo:
            self.photoBtn.isSelected = true
            self.photoBtn.tintColor = UIColor.green
            self.messageTextViewL.constant = 105
        }

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    private func defaultText() {
        self.messageTextView.text = "Aa"
        self.messageTextView.textColor = UIColor.gray
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
        return (photo.imgData.base64Image() ?? #imageLiteral(resourceName: "avatar"),
                member.publicInfo.fn)
    }

    @objc private func tapScreen() {
        self.messageTextView.endEditing(true)
        self.setMessageBottom(height: 0, mode: .Init)
    }

    @objc private func loadPreviusData() {
        guard self.messages.count > 0 else {
            self.refresher.endRefreshing()
            return
        }
        let seq = self.messages[0].seq
        self.status = .Previus
        self.socket.GetData(topic: self.topic,
                            what: [.data], before: seq)
    }

    private func chatTableReload() {
        if self.refresher.isRefreshing {
            self.messages = self.received + self.messages
        } else {
            self.messages = self.messages + self.received
        }

        self.chatTable.reloadData()

        if self.refresher.isRefreshing {
            self.refresher.endRefreshing()
            let idx = self.received.count
            let path = IndexPath(row: idx-1,
                                 section: 0)
            self.chatTable.scrollToRow(at: path, at: .top,
                                       animated: false)
        } else {
            self.view.hideToastActivity()
            if self.messages.count > 0 {
                let path = IndexPath(row: self.messages.count-1,
                                     section: 0)
                self.chatTable.scrollToRow(at: path, at: .top,
                                           animated: false)
            }
        }

        self.received.removeAll()
        self.status = .Standby
    }

    private func insertData(_ data: DataVarModel) {
        guard let last = self.messages.filter({$0.seq <= data.seq}).last else {
            self.messages.append(data)
            let idx = self.messages.count - 1
            let path = IndexPath(row: idx, section: 0)
            self.chatTable.beginUpdates()
            self.chatTable.insertRows(at: [path], with: .fade)
            self.chatTable.endUpdates()
            self.chatTable.scrollToRow(at: path, at: .top, animated: true)
            self.sendNote(seq: data.seq)
            return
        }

        if last.seq < data.seq {
            let idx = self.messages.index(where: {$0.seq == last.seq})!
            self.messages.insert(data, at: idx+1)
            let path = IndexPath(row: idx+1, section: 0)
            self.chatTable.beginUpdates()
            self.chatTable.insertRows(at: [path], with: .fade)
            self.chatTable.endUpdates()
            self.chatTable.scrollToRow(at: path, at: .top, animated: true)
            self.sendNote(seq: data.seq)
        }
    }

    private func sendNote(seq: Int, isRead: Bool=true) {
        let recv = NoteModel(topic: self.topic,
                             what: .recv, seq: seq)
        self.socket.sendNote(recv)

        if isRead {
            let read = NoteModel(topic: self.topic,
                                 what: .read, seq: seq)
            self.socket.sendNote(read)
        }
    }

    private func preparePhotoVC() {

        guard let vc = self.childViewControllers.first(where: {$0 is PhotoVC})
            as? PhotoVC  else {
            return
        }
        vc.delegate = self
        vc.prepareForShow()
    }
}

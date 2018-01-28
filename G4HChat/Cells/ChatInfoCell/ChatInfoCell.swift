//
//  ChatInfoCell.swift
//  G4HChat
//
//  Created by Codegreen on 27/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit

class ChatInfoCell: UITableViewCell {
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet private var unReadView: UIView!
    @IBOutlet private var unReadLabel: UILabel!

    var isOnline: Bool = false {
        didSet {
            let hex = (isOnline) ? Configure.onlineGreen: Configure.offlineGray
            self.avatar.setBoardColor(hex: hex, width: 5.0)
        }
    }

    private var _unReadNum: Int = 0
    var unReadNum: Int {
        set {
            if newValue <= 0 {
                self._unReadNum = 0
                self.unReadView.isHidden = true
                self.unReadLabel.text = "0"
            } else {
                self._unReadNum = newValue
                self.unReadView.isHidden = false
                self.unReadLabel.text = (newValue > 9) ? "9+": "\(newValue)"
            }
        }
        get {
            return self._unReadNum
        }
    }

    class func nib() -> UINib {
        return UINib(nibName: "ChatInfoCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.unReadView.roundCorner()
        self.avatar.roundCorner()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

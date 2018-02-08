//
//  TextMsgCell.swift
//  G4HChat
//
//  Created by 陳建佑 on 28/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit

class TextMsgCell: UITableViewCell {

    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var bubble: UIView!
    @IBOutlet var message: UITextView!
    @IBOutlet var timeLabel: UILabel!

    @IBOutlet var messageMaxWidth: NSLayoutConstraint!
    private var bubbleEdge: NSLayoutConstraint?
    private var bubbleTop: NSLayoutConstraint?
    private var timeEdge: NSLayoutConstraint?
    var isIncoming: Bool = false {
        willSet {
            if self.bubbleEdge != nil {
                self.contentView.removeConstraints([self.bubbleTop!,
                                                    self.bubbleEdge!,
                                                    self.timeEdge!])
            }
            (newValue) ? self.inComingLayout(): self.outGoingLayout()
        }
    }

    class func nib() -> UINib {
        return UINib(nibName: "TextMsgCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bubble.setCorner(radius: 17)
        self.avatar.setCorner(radius: 25)
        let width = UIScreen.main.bounds.size.width
        self.messageMaxWidth.constant = 0.7 * width
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func inComingLayout() {
        self.bubbleEdge = NSLayoutConstraint(item: self.bubble,
                                             attribute: .leading,
                                             relatedBy: .equal,
                                             toItem: self.avatar,
                                             attribute: .trailing,
                                             multiplier: 1, constant: 8)
        self.bubbleTop = NSLayoutConstraint(item: self.bubble,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: self.name,
                                            attribute: .bottom,
                                            multiplier: 1, constant: 8)
        self.timeEdge = NSLayoutConstraint(item: self.timeLabel,
                                           attribute: .leading,
                                           relatedBy: .equal,
                                           toItem: self.avatar,
                                           attribute: .trailing,
                                           multiplier: 1, constant: 8)
        self.contentView.addConstraints([self.bubbleTop!,
                                         self.bubbleEdge!,
                                         self.timeEdge!])
        self.bubble.backgroundColor = UIColor(hex: Configure.incomingColor)
        self.message.textColor = UIColor.black
        self.avatar.isHidden = false
        self.name.isHidden = false
    }

    private func outGoingLayout() {
        self.bubbleEdge = NSLayoutConstraint(item: self.bubble,
                                             attribute: .trailing,
                                             relatedBy: .equal,
                                             toItem: self.contentView,
                                             attribute: .trailing,
                                             multiplier: 1, constant: -8)
        self.bubbleTop = NSLayoutConstraint(item: self.bubble,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: self.contentView,
                                            attribute: .top,
                                            multiplier: 1, constant: 8)
        self.timeEdge = NSLayoutConstraint(item: self.timeLabel,
                                           attribute: .trailing,
                                           relatedBy: .equal,
                                           toItem: self.contentView,
                                           attribute: .trailing,
                                           multiplier: 1,
                                           constant: -8)
        self.contentView.addConstraints([self.bubbleTop!,
                                         self.bubbleEdge!,
                                         self.timeEdge!])
        self.bubble.backgroundColor = UIColor(hex: Configure.outgoingColor)
        self.message.textColor = UIColor.white
        self.avatar.isHidden = true
        self.name.isHidden = true
    }
}

//
//  ImageMsgCell.swift
//  G4HChat
//
//  Created by 陳建佑 on 05/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit

class ImageMsgCell: UITableViewCell {

    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var photo: UIImageView!
    @IBOutlet var timeLabel: UILabel!

    private var photoWidth: NSLayoutConstraint?
    private var photoHeight: NSLayoutConstraint?
    private var timeEdge: NSLayoutConstraint?
    private var photoEdge: NSLayoutConstraint?
    private var photoTop: NSLayoutConstraint?

    var isIncoming: Bool = false {
        willSet {
            if self.photoEdge != nil {
                self.contentView.removeConstraints([self.photoEdge!,
                                                    self.photoTop!,
                                                    self.timeEdge!])
            }
            (newValue) ? self.inComingLayout(): self.outGoingLayout()
        }
    }

    class func nib() -> UINib {
        return UINib(nibName: "ImageMsgCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatar.setCorner(radius: 25)
        self.photo.setCorner(radius: 20)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func inComingLayout() {
        self.photoEdge = NSLayoutConstraint(item: self.photo,
                                             attribute: .leading,
                                             relatedBy: .equal,
                                             toItem: self.avatar,
                                             attribute: .trailing,
                                             multiplier: 1, constant: 8)
        self.photoTop = NSLayoutConstraint(item: self.photo,
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
        self.contentView.addConstraints([self.photoEdge!,
                                         self.photoTop!,
                                         self.timeEdge!])
        self.avatar.isHidden = false
        self.name.isHidden = false
    }

    private func outGoingLayout() {
         self.photoEdge = NSLayoutConstraint(item: self.photo,
                                             attribute: .trailing,
                                             relatedBy: .equal,
                                             toItem: self.contentView,
                                             attribute: .trailing,
                                             multiplier: 1, constant: -8)
        self.photoTop = NSLayoutConstraint(item: self.photo,
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
        self.contentView.addConstraints([self.photoEdge!,
                                         self.photoTop!,
                                         self.timeEdge!])
        self.avatar.isHidden = true
        self.name.isHidden = true
    }

    func setAppropriateSize(origin: CGSize) {
        if self.photoWidth != nil {
            self.photo.removeConstraints([self.photoWidth!, self.photoHeight!])
        }

        let size = UIScreen.main.bounds.size
        let maxH = size.height * 0.5
        let maxW = size.width * 0.7
        let factor = origin.width / origin.height
        var w: CGFloat = 0
        var h: CGFloat = 0
        if origin.height <= maxH && origin.width <= maxW {
            w = origin.width
            h = origin.height
        } else if origin.height <= origin.width {
            w = maxW
            h = maxW / factor
        } else {
            h = maxH
            w = factor * maxH
        }

        self.photoWidth = NSLayoutConstraint(item: self.photo,
                                             attribute: .width,
                                             relatedBy: .equal,
                                             toItem: nil,
                                             attribute: .notAnAttribute,
                                             multiplier: 1, constant: w)
        self.photoHeight = NSLayoutConstraint(item: self.photo,
                                             attribute: .height,
                                             relatedBy: .equal,
                                             toItem: nil,
                                             attribute: .notAnAttribute,
                                             multiplier: 1, constant: h)
        self.photoHeight?.priority = UILayoutPriority(rawValue: 999)
        self.photo.addConstraints([self.photoWidth!, self.photoHeight!])
    }
}

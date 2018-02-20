//
//  PhotoDisplayCell.swift
//  G4HChat
//
//  Created by Codegreen on 15/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit
protocol PhotoDisplayDelegate {
    func sendPhoto(at: IndexPath)
}

class PhotoDisplayCell: UICollectionViewCell {

    @IBOutlet var thumbnailImage: UIImageView!
    @IBOutlet private var sendView: UIView!
    @IBOutlet private var sendBtn: UIButton!
    var indexPath: IndexPath!
    var representedAssetIdentifier: String!
    var delegate: PhotoDisplayDelegate?
    private var effectView: UIVisualEffectView?

    class func nib() -> UINib {
        return UINib(nibName: "PhotoDisplayCell", bundle: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.setBlurEffect(isRemove: true)
        self.thumbnailImage.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.sendView.setBoardColor(hex: "FFFFFF", width: 3)
        let width = self.sendView.bounds.size.width
        self.sendView.setCorner(radius: 0.5 * width)
    }

    func setBlurEffect(isRemove: Bool) {
        if isRemove {
            guard let effectView = self.effectView else {return}
            effectView.removeFromSuperview()
            self.sendView.isHidden = true
        } else {
            let blur = UIBlurEffect(style: .light)
            self.effectView = UIVisualEffectView(effect: blur)
            self.effectView?.frame = self.thumbnailImage.frame
            self.sendView.isHidden = false
            self.thumbnailImage.addSubview(self.effectView!)
        }
    }

    @IBAction func clickSendBtn(_ sender: Any) {
        self.delegate?.sendPhoto(at: self.indexPath)
    }
}

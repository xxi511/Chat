//
//  PhotoVC.swift
//  G4HChat
//
//  Created by 陳建佑 on 12/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit
import Photos

protocol PhotoVCDelegate {
    func photoPermissionDenied()
}

class PhotoVC: UIViewController {

    @IBOutlet var photoCollection: UICollectionView!
    let manager = PHImageManager()
    var photos: [UIImage]?
    var delegate: PhotoVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: UICollection
extension PhotoVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.photos != nil) ? self.photos!.count: 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

// MARK: Initialize
extension PhotoVC {
    func prepareForShow() {
        // Run when the view will show
        // In chatroom, this view is not visible at begining
        guard self.checkPermission() else {return}
        self.photos = [UIImage]()
        self.fetchImages()
    }

    private func checkPermission() -> Bool {
        let status =  PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            return true
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (auth) in
                if auth == .authorized {
                    //
                } else {
                    self.delegate?.photoPermissionDenied()
                }
            })
            return false
        } else {
            self.showPermissionAlert()
            return false
        }
    }

    private func fetchImages() {
        let fetchOption = PHFetchOptions()
        let predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        fetchOption.predicate = predicate
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOption.sortDescriptors = [sort]
        let allPhotos = PHAsset.fetchAssets(with: fetchOption)

        let size = CGSize(width: 240, height: 240)
        for i in 0..<allPhotos.count {
            let asset = allPhotos.object(at: i)
            self.manager.requesti
            self.manager.requestImage(for: asset, targetSize: size,
                                      contentMode: .aspectFill, options: nil,
                                      resultHandler: { (image, info) in

                                        if image != nil {
                                            self.photos?.append(image!)
                                        }
            })
        }

        self.photoCollection.reloadData()
    }
}

// MARK: Funcs
extension PhotoVC {
    func showPermissionAlert() {
        let title = "We need photo library permission"
        let msg = "To share photo to your friend, we need the permission"
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .default) { (_) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        let cancel = UIAlertAction(title: "No", style: .cancel) { _ in
            self.delegate?.photoPermissionDenied()
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}

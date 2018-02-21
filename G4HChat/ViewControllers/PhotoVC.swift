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
    func wantToSendImage(image: UIImage)
}

class PhotoVC: UIViewController {

    @IBOutlet var photoCollection: UICollectionView!
    var delegate: PhotoVCDelegate?

    private let photoCell = "photoCell"
    private let targetSize = CGSize(width: 240, height: 240)
    private var manager: PHCachingImageManager?
    private var photos: PHFetchResult<PHAsset>?
    private var previousPreheatRect = CGRect.zero
    private var selectedPath: IndexPath?


    override func viewDidLoad() {
        super.viewDidLoad()

        self.photoCollection.register(PhotoDisplayCell.nib(), forCellWithReuseIdentifier: self.photoCell)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: UICollection
extension PhotoVC: UICollectionViewDelegate, UICollectionViewDataSource, PhotoDisplayDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.photos != nil) ? self.photos!.count: 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.photoCell, for: indexPath) as! PhotoDisplayCell

        let asset = self.photos?.object(at: indexPath.row)
        cell.delegate = self
        cell.indexPath = indexPath
        cell.representedAssetIdentifier = (asset?.localIdentifier)!
        self.manager!.requestImage(for: asset!, targetSize: self.targetSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset?.localIdentifier && image != nil {
                cell.thumbnailImage.image = image
            }
        })

        if let row = self.selectedPath?.row, row == indexPath.row {
            cell.setBlurEffect(isRemove: false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.selectedPath != nil {
            self.setCellSelect(at: self.selectedPath!,
                               isSelect: false)
        }
        self.setCellSelect(at: indexPath, isSelect: true)
        self.selectedPath = indexPath
    }

    func sendPhoto(at: IndexPath) {
        let photoAsset = self.photos![at.row]
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        let imageManager = PHImageManager()
        imageManager.requestImage(for: photoAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { (image, _) in
            guard let image = image else {
                return
            }
            self.delegate?.wantToSendImage(image: image)
        }
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension PhotoVC: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {

        guard let changes = changeInstance.changeDetails(for: self.photos!) else {return}

        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            self.handleChange(changes: changes)
        }

    }

    private func handleChange(changes: PHFetchResultChangeDetails<PHAsset>) {
        // Hang on to the new fetch result.
        self.photos = changes.fetchResultAfterChanges
        if changes.hasIncrementalChanges {
            // If we have incremental diffs, animate them in the collection view.
            guard let collectionView = self.photoCollection else { fatalError() }
            collectionView.performBatchUpdates({
                // For indexes to make sense, updates must be in this order:
                // delete, insert, reload, move
                if let removed = changes.removedIndexes,
                    !removed.isEmpty {
                    collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                }
                if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                    collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                }
                if let changed = changes.changedIndexes, !changed.isEmpty {
                    collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
                changes.enumerateMoves { fromIndex, toIndex in
                    collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                            to: IndexPath(item: toIndex, section: 0))
                }
            })
        } else {
            // Reload the collection view if incremental diffs are not available.
            self.photoCollection.reloadData()
        }
        self.resetCachedAssets()
    }

    private func resetCachedAssets() {
        self.manager!.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }

    private func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }

        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: self.photoCollection!.contentOffset, size: self.photoCollection!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)

        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }

        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = self.differencesBetweenRects(previousPreheatRect, preheatRect)
        
        let addedAssets = addedRects
            .flatMap { rect in self.photoCollection.indexPathsForElements(in: rect) }
            .map { indexPath in self.photos!.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in self.photoCollection.indexPathsForElements(in: rect) }
            .map { indexPath in self.photos!.object(at: indexPath.item) }

        // Update the assets the PHCachingImageManager is caching.
        self.manager!.startCachingImages(for: addedAssets,
                                        targetSize: self.targetSize, contentMode: .aspectFill, options: nil)
        self.manager!.stopCachingImages(for: removedAssets,
                                       targetSize: self.targetSize, contentMode: .aspectFill, options: nil)

        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect
    }

    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
}

// MARK: UIScrollView
extension PhotoVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateCachedAssets()
    }
}

// MARK: Initialize
extension PhotoVC {
    func prepareForShow() {
        // Run when the view will show
        // In chatroom, this view is not visible at begining
        guard self.checkPermission() else {return}
        self.manager = PHCachingImageManager()
        PHPhotoLibrary.shared().register(self)
        self.resetCachedAssets()
        self.fetchImages()
    }

    private func checkPermission() -> Bool {
        let status =  PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            return true
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (auth) in
                if auth == .authorized {
                    self.prepareForShow()
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
        self.photos = allPhotos
        self.photoCollection.reloadData()
    }
}

// MARK: Funcs
extension PhotoVC {
    private func showPermissionAlert() {
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

    private func setCellSelect(at: IndexPath, isSelect: Bool) {
        guard let cell = self.photoCollection.cellForItem(at: at) as? PhotoDisplayCell else {
            return
        }
        cell.setBlurEffect(isRemove: !isSelect)
    }
}

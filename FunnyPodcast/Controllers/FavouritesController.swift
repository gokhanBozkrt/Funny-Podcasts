//
//  FavouritesController.swift
//  FunnyPodcast
//
//  Created by Gokhan on 23.09.2024.
//

import UIKit

fileprivate let cellId = "cellid"


class FavouritesController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    var podcasts: [Podcast] = UserDefaults.getSavedPodcasts() ?? []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(FavouritesCell.self, forCellWithReuseIdentifier: cellId)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector (handleLongPress))
        collectionView.addGestureRecognizer(gesture)
        
    }

    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
   
            let location = gesture.location(in: collectionView)
            guard let indexPath = collectionView.indexPathForItem(at: location) else { return }
        
        let alertController = UIAlertController(title: "Remove Podcast", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] _ in
        
            guard let self else { return }
            podcasts.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
            
            UserDefaults.deleteSavedPodcasts(podcasts: podcasts)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController,animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? FavouritesCell else {
            return UICollectionViewCell()
        }
        
        cell.podcast = podcasts[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (view.frame.width - 3 * 16) / 2
        return CGSize(width: width, height: width + 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        16
    }
}

#Preview {
    let vc = FavouritesController(collectionViewLayout: UICollectionViewFlowLayout())
    return vc
}



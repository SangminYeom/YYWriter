//
//  PhotoStreamViewControllerCollectionViewController.swift
//  YYWriter
//
//  Created by SANGMIN YEOM on 2021/11/24.
//

import UIKit
import AVFoundation

private let reuseIdentifier = "Cell"

class PhotoStreamViewController: UICollectionViewController {
    

    var photos : Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Pattern"))

//        if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
//            layout.delegate = self
//        }
        
        collectionView!.delegate = self
        
        collectionView!.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        if #available(iOS 11.0, *) {
          collectionView?.contentInsetAdjustmentBehavior = .always
        }
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        photos = Photo()
        photos.refresh() {
            self.collectionView.reloadData()
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        
        if distanceFromBottom < height {
            print("you reached end of the table")
            photos.loadPastPosts()
            self.collectionView!.reloadData()
        }
    }
}

extension PhotoStreamViewController {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      print(photos.loadedPosts.count)
      return photos.loadedPosts.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnnotatedPhotoCell", for: indexPath) as! PhotoCell
      
      
      let aPhoto = photos.loadedPosts[indexPath.row]
      cell.photo.image = aPhoto.imageView.image
      cell.comment.text = aPhoto.text
      
      return cell
  }
}

extension PhotoStreamViewController : PinterestLayoutDelegate {
  func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath,
                      withWidth width: CGFloat) -> CGFloat {
      let photo = photos.loadedPosts[(indexPath as NSIndexPath).item]
      let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
      let rect  = AVMakeRect(aspectRatio: photo.imageView.image!.size, insideRect: boundingRect)
      return rect.size.height
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
      let annotationPadding = CGFloat(4)
      let annotationHeaderHeight = CGFloat(17)
      let photo = photos.loadedPosts[(indexPath as NSIndexPath).item]
      let font = UIFont(name: "AvenirNext-Regular", size: 10)!
      let commentHeight = heightForComment(photo.text, font, width: width)
      let height = annotationPadding + annotationHeaderHeight + commentHeight + annotationPadding
      return height
  }
    
    func heightForComment(_ comment: String, _ font: UIFont, width: CGFloat) -> CGFloat {
      let rect = NSString(string: comment).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
      return ceil(rect.height)
    }
}

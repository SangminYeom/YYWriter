import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseStorageUI
import AVFAudio
import AVFoundation

class Photo {
    var databaseRef : DatabaseReference?
    var storageRef : StorageReference?
    
    var posts = [Post]()
    var loadedPosts = [Post]()
    
    init() {
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        loadPosts()
    }
    
    private func loadPosts() {
        var orderedQuery : DatabaseQuery?
        orderedQuery = databaseRef?.child("posts").queryOrdered(byChild: "date")
        orderedQuery?.observeSingleEvent(of: .value) { (snapshot) in
            var snapshotData = snapshot.children.allObjects
            snapshotData = snapshotData.reversed()
            
            for anyDatum in snapshotData {
                let snapshotDatum = anyDatum as! DataSnapshot
                let dicDatum = snapshotDatum.value as! [String:String]
                if let text = dicDatum["text"],
                   let date = Int(dicDatum["date"]!) {
                    let post = Post(text,date)
                    
                    let imageRef = self.storageRef?.child("\(snapshotDatum.key).jpg")
                    post.imageView.sd_setImage(with: imageRef!, placeholderImage: UIImage()) { (_,_,_,_) in
                        // 이미지 셋 하고 나서.. 할일이 없음..
                    }
                    self.loadedPosts += [post]
                }
            }
            
            self.posts += self.loadedPosts.prefix(g_NumPerOneLoad)
        }
    }
    
    private func loadFreshPosts() {
        var filteredQuery : DatabaseQuery?
        
        if let lateDate = self.posts.first?.date {
            filteredQuery = databaseRef?.child("posts").queryOrdered(byChild: "date").queryStarting(atValue: "\(lateDate + 1)")
        } else {
            filteredQuery = databaseRef?.child("posts").queryOrdered(byChild: "date").queryStarting(atValue: "\(0)")
        }
        
        filteredQuery?.observeSingleEvent(of: .value) { (snapshot) in
            var snapshotData = snapshot.children.allObjects
            snapshotData = snapshotData.reversed()
            
            var freshPostsChunk = [Post]()
            
            for anyDatum in snapshotData {
                let snapshotDatum = anyDatum as! DataSnapshot
                let dicDatum = snapshotDatum.value as! [String:String]
                
                if let text = dicDatum["text"],
                   let date = Int(dicDatum["date"]!) {
                    let post = Post(text,date)
                    
                    let imageRef = self.storageRef?.child("\(snapshotDatum.key).jpg")
                    post.imageView.sd_setImage(with: imageRef!, placeholderImage: UIImage()) {
                        (_,_,_,_) in
                        // 할일이 없음
                    }
                    freshPostsChunk += [post]
                }
            }
            
            self.loadedPosts.insert(contentsOf: freshPostsChunk, at: 0)
            self.posts.insert(contentsOf: freshPostsChunk, at: 0)
        }
    }
    
    func loadPastPosts() {
        let pastPosts = self.loadedPosts.filter({$0.date < (self.posts.last?.date)!})
        let pastChunkPosts = pastPosts.prefix(g_NumPerOneLoad)
        
        if pastChunkPosts.count > 0 {
            self.posts += pastChunkPosts
        }
    }
    
    func refresh(completionHandler: ()->Void) {
        self.loadFreshPosts()
        
        completionHandler()
    }
    
}

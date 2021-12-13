import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseStorageUI
import AVFAudio
import AVFoundation

class TimeLineTableViewController : UITableViewController {
    var databaseRef : DatabaseReference?
    var storageRef : StorageReference?
    
    
    var posts = [Post]()
    var loadedPosts = [Post]()
    
    @IBOutlet weak var footerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        loadPosts()
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(TimeLineTableViewController.refresh), for: .valueChanged)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeLineCell", for: indexPath) as! TimeLineTableViewCell
        let post = posts[indexPath.row]
        
        cell.timeContents.text = post.text
        cell.timeImage.image = post.imageView.image
        
        return cell
    }
    
    func loadPosts() {
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
                        self.tableView.reloadData()
                    }
                    self.loadedPosts += [post]
                }
            }
            
            self.posts += self.loadedPosts.prefix(g_NumPerOneLoad)
            self.tableView.reloadData()
        }
    }
    
    @objc func refresh() {
        print("refresh")
        self.loadFreshPosts()
        self.refreshControl?.endRefreshing()
    }
    
    func loadFreshPosts() {
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
                        self.tableView.reloadData()
                    }
                    freshPostsChunk += [post]
                }
            }
            
            self.loadedPosts.insert(contentsOf: freshPostsChunk, at: 0)
            self.posts.insert(contentsOf: freshPostsChunk, at: 0)
            self.tableView.reloadData()
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height
        + self.footerLabel.frame.height - contentYoffset
        
        if distanceFromBottom < height {
            print("you reached end of the table")
            loadPastPosts()
        }
    }
    
    func loadPastPosts() {
        let pastPosts = self.loadedPosts.filter({$0.date < (self.posts.last?.date)!})
        let pastChunkPosts = pastPosts.prefix(g_NumPerOneLoad)
        
        if pastChunkPosts.count > 0 {
            self.posts += pastChunkPosts
            sleep(1)
            self.tableView.reloadData()
        }
    }
}

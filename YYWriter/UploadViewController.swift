import UIKit
import FirebaseDatabase
import FirebaseStorage

class UploadViewController : UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var uploadContents: UITextView!
    @IBOutlet weak var uploadImage: UIImageView!
    
    var image = UIImage()
    let placeHolder = "하고 싶은 말이 있나요?"
    
    var databaseRef : DatabaseReference?
    var storageRef : StorageReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        self.uploadContents.delegate = self
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(uploadPost))
        
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.uploadImage.image = self.image
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func uploadPost() {
        let curRef = self.databaseRef?.child("posts").childByAutoId()
        if self.uploadContents.text != placeHolder {
            curRef?.child("text").setValue(self.uploadContents.text)
        } else {
            curRef?.child("text").setValue("")
        }
        
        self.uploadContents.text = ""
        textViewDidEndEditing(uploadContents)
        
        let date = Date()
        let intValueOfDate = Int(date.timeIntervalSince1970)
        curRef?.child("date").setValue("\(intValueOfDate)")
        
        let imageRef = storageRef?.child((curRef?.key)! + ".jpg")
        
        guard let uploadData = self.image.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        imageRef?.putData(uploadData, metadata: nil, completion: {metaData, error in
            if let error = error {
                NSLog("\(error.localizedDescription)")
            } else {
                //NSLog("\(metaData?.description)")
                // 새로고침 해야 함
                
            }
        })
        
        self.tabBarController?.selectedIndex = 0
        
    }
    
    func placeHoderSetting() {
        uploadContents.text = placeHolder
        uploadContents.textColor = UIColor.lightGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolder
            textView.textColor = UIColor.lightGray
        }
    }
    
}

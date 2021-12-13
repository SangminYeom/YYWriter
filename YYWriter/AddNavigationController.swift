import UIKit
import Fusuma

class AddNavigationController : UINavigationController, FusumaDelegate {

    let fusuma = FusumaViewController()
    var uploadController = UploadViewController()
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fusumaTintColor = UIColor.black
        fusumaBaseTintColor = UIColor.black
        fusumaBackgroundColor = UIColor.white
        
        fusuma.delegate = self
        fusuma.cropHeightRatio = 0.6
        fusuma.allowMultipleSelection = false
        fusuma.hidesBottomBarWhenPushed = true
        
        uploadController = storyBoard.instantiateViewController(withIdentifier: "UploadViewController") as! UploadViewController
        uploadController.navigationItem.title = "업로드"
        
        self.pushViewController(fusuma, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.isNavigationBarHidden = true
        self.popToViewController(fusuma, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fusumaWillClosed() {
        self.tabBarController?.selectedIndex = 0
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        uploadController.image = image
        self.pushViewController(uploadController, animated: false)
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        //
    }
    
    func fusumaCameraRollUnauthorized() {
        //
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        //
    }
    
}

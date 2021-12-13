import UIKit
import Foundation

let g_NumPerOneLoad = 3

class Post {
    var text: String
    var date: Int
    var imageView =  UIImageView()
    
    init(_ text:String, _ date:Int) {
        self.text = text
        self.date = date
    }
}

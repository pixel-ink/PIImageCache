import UIKit

class ViewController: UIViewController {

  let cache = PIImageCache()

  @IBOutlet var imgView: UIImageView!
  
  @IBAction func btnPushed(sender: AnyObject) {
    let url = NSURL(string: "http://lorempixel.com/200/200/")!
    imgView.image = cache.download(url)
  }
  
}


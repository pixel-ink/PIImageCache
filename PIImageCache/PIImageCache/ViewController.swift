import UIKit

class ViewController: UIViewController {
  
  let cache = PIImageCache()
  
  let lormpixelCategory =
  [
    "animals",
    "cats",
    "city",
    "fashion"
  ]
  var count = 0
  @IBOutlet var imgView: UIImageView!
  
  @IBAction func btnPushed(sender: AnyObject) {
    count++
    if count >= lormpixelCategory.count {
      count = 0
    }
    let url = NSURL(string: "http://lorempixel.com/200/200/" + lormpixelCategory[count] )!
    imgView.imageOfURL(url)
  }
  
  override func didReceiveMemoryWarning() {
    cache.allMemoryCacheDelete()
  }
  
}
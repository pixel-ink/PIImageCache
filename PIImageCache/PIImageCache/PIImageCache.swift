
// https://github.com/pixel-ink/PIImageCache

import UIKit

class PIImageCache {

  func download(url: NSURL) -> UIImage? {
    var err: NSError?
    var imageData :NSData = NSData(contentsOfURL: url, options:.UncachedRead, error: &err)!
    if let e = err { println(e) }
    return UIImage(data: imageData)
  }
  
}
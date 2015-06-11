
// https://github.com/pixel-ink/PIImageCache

import UIKit

extension NSURL {
  func getImageWithCache(cache: PIImageCache) -> UIImage? {
    return cache.get(self)
  }
}

class PIImageCache {

  struct cacheImage {
    let image     :UIImage
    var timeStump :Double
    let url       :NSURL
  }

  var now: Double {
    get {
      return NSDate().timeIntervalSince1970
    }
  }
  
  var cache : [cacheImage] = []

  func cacheRead(url: NSURL) -> UIImage? {
    for var i=0; i<cache.count; i++ {
      if url == cache[i].url {
        cache[i].timeStump = now
        return cache[i].image
      }
    }
    return nil
  }
  
  func get(url: NSURL) -> UIImage? {
    let cache = cacheRead(url)
    if cache != nil {
      println("hit")
      return cache
    }
    println("mishit")
    let maybeImage = download(url)
    if let image = maybeImage {
      cacheSet(url, image: image)
    }
    return maybeImage
  }

  func cacheSet(url:NSURL,image:UIImage) {
    if cache.count < 10 {
      cache.append(cacheImage(image: image, timeStump: now, url: url))
    } else {
      var old = (0,now)
      for var i=0; i<cache.count; i++ {
        if old.1 < cache[i].timeStump {
          old = (i,cache[i].timeStump)
        }
        cache.removeAtIndex(old.0)
        cache.append(cacheImage(image: image, timeStump:now, url: url))
      }
    }
  }
  
  func download(url: NSURL) -> UIImage? {
    var err: NSError?
    var imageData :NSData = NSData(contentsOfURL: url, options:.UncachedRead, error: &err)!
    if let e = err { println(e) }
    return UIImage(data: imageData)
  }
  
}

// https://github.com/pixel-ink/PIImageCache

import UIKit

extension NSURL {
  func getImageWithCache(cache: PIImageCache) -> UIImage? {
    return cache.get(self)
  }
}

extension UIImageView {
  func imageOfURL(url: NSURL, cache: PIImageCache) {
    cache.get(url) {
      [weak self] img in
      self?.image = img
    }
  }
}

class PIImageCache {
  
  init() {
    maxCount = 10
  }

  init(maxCount: Int) {
    self.maxCount = maxCount
  }
  
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
  
  let maxCount : Int
  
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
  
  func cacheWrite(url:NSURL,image:UIImage) {
    if cache.count < maxCount {
      cache.append(cacheImage(image: image, timeStump: now, url: url))
    } else {
      var old = (0,now)
      for i in 0 ..< cache.count {
        if old.1 < cache[i].timeStump {
          old = (i,cache[i].timeStump)
        }
      }
      cache.removeAtIndex(old.0)
      cache.append(cacheImage(image: image, timeStump:now, url: url))
    }
  }
  
  func download(url: NSURL) -> UIImage? {
    var err: NSError?
    var maybeImageData = NSData(contentsOfURL: url, options:.UncachedRead, error: &err)
    if let e = err { println(e) }
    if let imageData = maybeImageData {
      return UIImage(data: imageData)
    } else {
      return nil
    }
  }
  
  func get(url: NSURL) -> UIImage? {
    return perform(url).0
  }
  
  func get(url: NSURL, then: (image:UIImage?) -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      [weak self] in
      if let scope = self {
        dispatch_async(dispatch_get_main_queue()) {
          then(image: scope.get(url))
        }
      }
    }
  }
  
  var semaphore = dispatch_semaphore_create(1)
  
  func perform(url: NSURL) -> (UIImage?, isCache:Bool) {
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER)
    let maybeCache = cacheRead(url)
    dispatch_semaphore_signal(semaphore)
    if let cache = maybeCache {
      return (cache, true)
    }
    let maybeImage = download(url)
    if let image = maybeImage {
      dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER)
      cacheWrite(url, image: image)
      dispatch_semaphore_signal(semaphore)
    }
    return (maybeImage, false)
  }
  
}
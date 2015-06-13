
// https://github.com/pixel-ink/PIImageCache

import UIKit

public extension NSURL {
  public func getImageWithCache(cache: PIImageCache) -> UIImage? {
    return cache.get(self)
  }
}

public extension UIImageView {
  public func imageOfURL(url: NSURL, cache: PIImageCache) {
    cache.get(url) {
      [weak self] img in
      self?.image = img
    }
  }
}

public class PIImageCache {
  
  public init() {}
  
  public init(config: Config) {
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER)
    self.config.maxCount = config.maxCount
    self.config.maxByteSize = config.maxByteSize
    dispatch_semaphore_signal(semaphore)
  }
  
  public class var shared: PIImageCache {
    struct Static {
      static let instance: PIImageCache = PIImageCache()
    }
    return Static.instance
  }
 
  public func get(url: NSURL) -> UIImage? {
    return perform(url).0
  }
  
  public func get(url: NSURL, then: (image:UIImage?) -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      [weak self] in
      if let scope = self {
        dispatch_async(dispatch_get_main_queue()) {
          then(image: scope.get(url))
        }
      }
    }
  }
  
  private struct cacheImage {
    let image     :UIImage
    var timeStamp :Double
    let url       :NSURL
  }
  
  private var now: Double {
    get {
      return NSDate().timeIntervalSince1970
    }
  }
  
  private var config: Config = Config()
  public class Config {
    public var maxCount : Int = 10
    public var maxByteSize  : Int = 3 * 1024 * 1024 //3MB
  }
  
  public func setConfig(config :Config) {
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER)
    self.config = config
    dispatch_semaphore_signal(semaphore)
  }
  
  private var cache : [cacheImage] = []
  private var semaphore = dispatch_semaphore_create(1)

  private func cacheRead(url: NSURL) -> UIImage? {
    for var i=0; i<cache.count; i++ {
      if url == cache[i].url {
        cache[i].timeStamp = now
        return cache[i].image
      }
    }
    return nil
  }
  
  private func cacheWrite(url:NSURL,image:UIImage) {
    switch cache.count {
    case 0 ... config.maxCount:
      cache.append(cacheImage(image: image, timeStamp: now, url: url))
    case config.maxCount + 1://+1 because 0 origin
      var old = (0,now)
      for i in 0 ..< cache.count {
        if old.1 < cache[i].timeStamp {
          old = (i,cache[i].timeStamp)
        }
      }
      cache.removeAtIndex(old.0)
      cache.append(cacheImage(image: image, timeStamp:now, url: url))
    default:
      for _ in 0 ... 1 {
        var old = (0,now)
        for i in 0 ..< cache.count {
          if old.1 < cache[i].timeStamp {
            old = (i,cache[i].timeStamp)
          }
        }
        cache.removeAtIndex(old.0)
      }
      cache.append(cacheImage(image: image, timeStamp:now, url: url))      
    }
  }
  
  internal func download(url: NSURL) -> (UIImage, byteSize: Int)? {
    var err: NSError?
    var maybeImageData = NSData(contentsOfURL: url, options:.UncachedRead, error: &err)
    if let e = err { println(e) }
    if let imageData = maybeImageData {
      if let image = UIImage(data: imageData) {
        let bytes = imageData.length
        return (image, bytes)
      }
    }
    return nil
  }
  
  internal func perform(url: NSURL) -> (UIImage?, isCache:Bool) {
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER)
    let maybeCache = cacheRead(url)
    dispatch_semaphore_signal(semaphore)
    if let cache = maybeCache {
      return (cache, true)
    }
    let maybeImage = download(url)
    if let (image, byteSize) = maybeImage {
      if byteSize < config.maxByteSize {
        dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER)
        cacheWrite(url, image: image)
        dispatch_semaphore_signal(semaphore)
      }
    }
    return (maybeImage?.0, false)
  }
  
}
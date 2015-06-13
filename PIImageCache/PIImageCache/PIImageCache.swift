
// https://github.com/pixel-ink/PIImageCache

import UIKit

public extension NSURL {
  public func getImageWithCache() -> UIImage? {
    return PIImageCache.shared.get(self)
  }
  
  public func getImageWithCache(cache: PIImageCache) -> UIImage? {
    return cache.get(self)
  }
}

public extension UIImageView {
  public func imageOfURL(url: NSURL) {
    PIImageCache.shared.get(url) {
      [weak self] img in
      self?.image = img
    }
  }
  
  public func imageOfURL(url: NSURL, cache: PIImageCache) {
    cache.get(url) {
      [weak self] img in
      self?.image = img
    }
  }

  public func imageOfURL(url: NSURL, then:(Bool)->Void) {
    PIImageCache.shared.get(url) {
      [weak self] img in
      let isOK = img != nil
      self?.image = img
      then(isOK)
    }
  }
  
  public func imageOfURL(url: NSURL, cache: PIImageCache, then:(Bool)->Void) {
    cache.get(url) {
      [weak self] img in
      let isOK = img != nil
      self?.image = img
      then(isOK)
    }
  }
}

public class PIImageCache {
  
  private func myInit() {
    folderCreate()
  }
  
  public init() {
    myInit()
  }
  
  public init(config: Config) {
    myInit()
    dispatch_semaphore_wait(memorySemaphore, DISPATCH_TIME_FOREVER)
    self.config = config
    dispatch_semaphore_signal(memorySemaphore)
  }
  
  public class var shared: PIImageCache {
    struct Static {
      static let instance: PIImageCache = PIImageCache()
    }
    Static.instance.myInit()
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
  
  private struct memoryCacheImage {
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
    public var maxCount : Int = 10 // 10 images
    public var maxByteSize  : Int = 3 * 1024 * 1024 //3MB
    public var usingDiskCache = true
    public var diskCacheExpireMinutes = 24 * 60 // 1 day
    public var cacheRootDirectory = NSTemporaryDirectory()
    public var cacheFolderName = "PIImageCache"
  }
  
  public func setConfig(config :Config) {
    dispatch_semaphore_wait(memorySemaphore,DISPATCH_TIME_FOREVER)
    self.config = config
    dispatch_semaphore_signal(memorySemaphore)
  }
  
  private var memoryCache : [memoryCacheImage] = []
  private var memorySemaphore = dispatch_semaphore_create(1)
  private let fileManager = NSFileManager.defaultManager()
  
  private func memoryCacheRead(url: NSURL) -> UIImage? {
    for var i=0; i<memoryCache.count; i++ {
      if url == memoryCache[i].url {
        memoryCache[i].timeStamp = now
        return memoryCache[i].image
      }
    }
    return nil
  }
  
  private func memoryCacheWrite(url:NSURL,image:UIImage) {
    switch memoryCache.count {
    case 0 ... config.maxCount:
      memoryCache.append(memoryCacheImage(image: image, timeStamp: now, url: url))
    case config.maxCount + 1://+1 because 0 origin
      var old = (0,now)
      for i in 0 ..< memoryCache.count {
        if old.1 < memoryCache[i].timeStamp {
          old = (i,memoryCache[i].timeStamp)
        }
      }
      memoryCache.removeAtIndex(old.0)
      memoryCache.append(memoryCacheImage(image: image, timeStamp:now, url: url))
    default:
      for _ in 0 ... 1 {
        var old = (0,now)
        for i in 0 ..< memoryCache.count {
          if old.1 < memoryCache[i].timeStamp {
            old = (i,memoryCache[i].timeStamp)
          }
        }
        memoryCache.removeAtIndex(old.0)
      }
      memoryCache.append(memoryCacheImage(image: image, timeStamp:now, url: url))
    }
  }
  
  private func folderCreate() {
    let path = "\(config.cacheRootDirectory)\(config.cacheFolderName)/"
    if fileManager.createDirectoryAtPath(
      path,
      withIntermediateDirectories: false,
      attributes: nil,
      error: nil){}
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
    dispatch_semaphore_wait(memorySemaphore,DISPATCH_TIME_FOREVER)
    let maybeCache = memoryCacheRead(url)
  internal enum Result {
    case Mishit, MemoryHit, DiskHit
  }
  
    dispatch_semaphore_signal(memorySemaphore)
    if let cache = maybeMemoryCache {
      return (cache, .MemoryHit)
    }
    let maybeImage = download(url)
    if let (image, byteSize) = maybeImage {
      if byteSize < config.maxByteSize {
        dispatch_semaphore_wait(memorySemaphore,DISPATCH_TIME_FOREVER)
        memoryCacheWrite(url, image: image)
        dispatch_semaphore_signal(memorySemaphore)
      }
    }
    return (maybeImage?.0, .Mishit)
  }
  
}
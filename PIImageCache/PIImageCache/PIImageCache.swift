
// https://github.com/pixel-ink/PIImageCache

import UIKit

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
    public var maxMemorySum           : Int    = 10 // 10 images
    public var limitByteSize          : Int    = 3 * 1024 * 1024 //3MB
    public var usingDiskCache         : Bool   = true
    public var diskCacheExpireMinutes : Int    = 24 * 60 // 1 day
    public var cacheRootDirectory     : String = NSTemporaryDirectory()
    public var cacheFolderName        : String = "PIImageCache"
  }
  
  public func setConfig(config :Config) {
    dispatch_semaphore_wait(memorySemaphore,DISPATCH_TIME_FOREVER)
    self.config = config
    dispatch_semaphore_signal(memorySemaphore)
  }
  
  private var memoryCache : [memoryCacheImage] = []
  private var memorySemaphore = dispatch_semaphore_create(1)
  private var diskSemaphore = dispatch_semaphore_create(1)
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
    case 0 ... config.maxMemorySum:
      memoryCache.append(memoryCacheImage(image: image, timeStamp: now, url: url))
    case config.maxMemorySum + 1://+1 because 0 origin
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
  
  private class func path(url: NSURL, config:Config) -> String? {
    if let urlstr = url.absoluteString {
      var code = ""
      for char in urlstr.utf8 {
        code = code + "u\(char)"
      }
      return "\(config.cacheRootDirectory)\(config.cacheFolderName)/\(code)"
    }
    return nil
  }
  
  private func diskCacheRead(url: NSURL) -> UIImage? {
    if let path = PIImageCache.path(url, config: config) {
      return UIImage(contentsOfFile: path)
    }
    return nil
  }
  
  private func diskCacheWrite(url:NSURL,image:UIImage) {
    if let path = PIImageCache.path(url, config: config) {
      NSData(data: UIImagePNGRepresentation(image)).writeToFile(path, atomically: true)
    }
  }
  
  public func allDiskCacheDelete() {
    dispatch_semaphore_wait(diskSemaphore, DISPATCH_TIME_FOREVER)
    let allFileName: [String]? = fileManager.contentsOfDirectoryAtPath("\(config.cacheRootDirectory)\(config.cacheFolderName)/", error: nil) as? [String]
    if let all = allFileName {
      for fileName in all {
        fileManager.removeItemAtPath("\(config.cacheRootDirectory)\(fileName)", error: nil)
      }
    }
    folderCreate()
    dispatch_semaphore_signal(diskSemaphore)
  }
  
  public func oldDiskCacheDelete() {
    let path = "\(config.cacheRootDirectory)\(config.cacheFolderName)/"
    dispatch_semaphore_wait(diskSemaphore, DISPATCH_TIME_FOREVER)
    let allFileName: [String]? = fileManager.contentsOfDirectoryAtPath(path, error: nil) as? [String]
    if let all = allFileName {
      for fileName in all {
        if let attr = fileManager.attributesOfFileSystemForPath("\(config.cacheRootDirectory)\(fileName)", error: nil) {
          let diff = NSDate().timeIntervalSinceDate( (attr[NSFileModificationDate] as? NSDate) ?? NSDate() )
          if Double(diff) > Double(config.diskCacheExpireMinutes * 60) {
            fileManager.removeItemAtPath("\(config.cacheRootDirectory)\(fileName)", error: nil)
          }
        }
      }
    }
    folderCreate()
    dispatch_semaphore_signal(diskSemaphore)
  }
  
  public func allMemoryCacheDelete() {
    dispatch_semaphore_wait(memorySemaphore, DISPATCH_TIME_FOREVER)
    memoryCache.removeAll(keepCapacity: false)
    dispatch_semaphore_signal(memorySemaphore)
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
  
  internal enum Result {
    case Mishit, MemoryHit, DiskHit
  }
  
  internal func perform(url: NSURL) -> (UIImage?, Result) {
    
    //memory read
    dispatch_semaphore_wait(memorySemaphore, DISPATCH_TIME_FOREVER)
    let maybeMemoryCache = memoryCacheRead(url)
    dispatch_semaphore_signal(memorySemaphore)
    if let cache = maybeMemoryCache {
      return (cache, .MemoryHit)
    }
    
    //disk read
    if config.usingDiskCache {
      dispatch_semaphore_wait(diskSemaphore, DISPATCH_TIME_FOREVER)
      let maybeDiskCache = diskCacheRead(url)
      dispatch_semaphore_signal(diskSemaphore)
      if let cache = maybeDiskCache {
        dispatch_semaphore_wait(memorySemaphore, DISPATCH_TIME_FOREVER)
        memoryCacheWrite(url, image: cache)
        dispatch_semaphore_signal(memorySemaphore)
        return (cache, .DiskHit)
      }
    }
    
    //download
    let maybeImage = download(url)
    if let (image, byteSize) = maybeImage {
      if byteSize < config.limitByteSize {
        //write memory
        dispatch_semaphore_wait(memorySemaphore, DISPATCH_TIME_FOREVER)
        memoryCacheWrite(url, image: image)
        dispatch_semaphore_signal(memorySemaphore)
        //write disk
        if config.usingDiskCache {
          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            [weak self] in
            if let scope = self {
              dispatch_semaphore_wait(scope.diskSemaphore, DISPATCH_TIME_FOREVER)
              scope.diskCacheWrite(url, image: image)
              dispatch_semaphore_signal(scope.diskSemaphore)
            }
          }
        }
      }
    }
    return (maybeImage?.0, .Mishit)
  }
  
}
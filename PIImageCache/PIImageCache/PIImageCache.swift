
// https://github.com/pixel-ink/PIImageCache

import UIKit

public class PIImageCache {
  
  //initialize
  
  private func myInit() {
    folderCreate()
    prefetchQueueInit()
  }
  
  public init() {
    myInit()
  }
  
  public init(config: Config) {
    dispatch_semaphore_wait(memorySemaphore, DISPATCH_TIME_FOREVER)
    self.config = config
    dispatch_semaphore_signal(memorySemaphore)
    myInit()
  }
  
  public class var shared: PIImageCache {
    struct Static {
      static let instance: PIImageCache = PIImageCache()
    }
    Static.instance.myInit()
    return Static.instance
  }
  
  //public config method
  
  public class Config {
    public var maxMemorySum           : Int    = 10 // 10 images
    public var limitByteSize          : Int    = 3 * 1024 * 1024 //3MB
    public var usingDiskCache         : Bool   = true
    public var diskCacheExpireMinutes : Int    = 24 * 60 // 1 day
    public var prefetchOprationCount  : Int    = 5
    public var cacheRootDirectory     : String = NSTemporaryDirectory()
    public var cacheFolderName        : String = "PIImageCache"
  }
  
  public func setConfig(config :Config) {
    dispatch_semaphore_wait(memorySemaphore,DISPATCH_TIME_FOREVER)
    self.config = config
    myInit()
    dispatch_semaphore_signal(memorySemaphore)
  }
  
  //public download method
  
  public func get(url: NSURL) -> UIImage? {
    return perform(url).0
  }
  
  public func get(url: NSURL, then: (image:UIImage?) -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      [weak self] in
      let image = self?.get(url)
      dispatch_async(dispatch_get_main_queue()) {
        then(image: image)
      }
    }
  }

  public func getWithId(url: NSURL, id: Int, then: (id: Int, image: UIImage?) -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      [weak self] in
      let image = self?.get(url)
      dispatch_async(dispatch_get_main_queue()) {
        then(id: id, image: image)
      }
    }
  }
  
  public func prefetch(urls: [NSURL]) {
    for url in urls {
      prefetch(url)
    }
  }
  
  public func prefetch(url: NSURL) {
    let op = NSOperation()
    op.completionBlock = {
      [weak self] in
      self?.downloadToDisk(url)
    }
    prefetchQueue.addOperation(op)
  }
  
  //public delete method
  
  public func allMemoryCacheDelete() {
    dispatch_semaphore_wait(memorySemaphore, DISPATCH_TIME_FOREVER)
    memoryCache.removeAll(keepCapacity: false)
    dispatch_semaphore_signal(memorySemaphore)
  }
  
  public func allDiskCacheDelete() {
    let path = PIImageCache.folderPath(config)
    dispatch_semaphore_wait(diskSemaphore, DISPATCH_TIME_FOREVER)
    do {
        let allFileName: [String]? = try fileManager.contentsOfDirectoryAtPath(path) as [String]
        if let all = allFileName {
            for fileName in all {
                do {
                    try fileManager.removeItemAtPath(path + fileName)
                } catch {
                    print("Error removing item form cache")
                }
            }
        }
    } catch {
        print("Error parsing directory")
    }
    folderCreate()
    dispatch_semaphore_signal(diskSemaphore)
  }
  
  public func oldDiskCacheDelete() {
    let path = PIImageCache.folderPath(config)
    dispatch_semaphore_wait(diskSemaphore, DISPATCH_TIME_FOREVER)
    do {
        let allFileName: [String]? = try fileManager.contentsOfDirectoryAtPath(path) as [String]
        if let all = allFileName {
            for fileName in all {
                do {
                    let attr = try fileManager.attributesOfItemAtPath(path + fileName)
                    let diff = NSDate().timeIntervalSinceDate( (attr[NSFileModificationDate] as? NSDate) ?? NSDate() )
                    if Double(diff) > Double(config.diskCacheExpireMinutes * 60) {
                        do {
                            try fileManager.removeItemAtPath(path + fileName)
                        } catch {
                            print("Error removing item from cache")
                        }
                    }
                } catch {
                    print("Error getting attributes from item")
                }
            }
        }
    } catch {
        print("Error parsing directory")
    }
    folderCreate()
    dispatch_semaphore_signal(diskSemaphore)
  }
  
  //member
  
  private var config: Config = Config()
  private var memoryCache : [memoryCacheImage] = []
  private var memorySemaphore = dispatch_semaphore_create(1)
  private var diskSemaphore = dispatch_semaphore_create(1)
  private let fileManager = NSFileManager.defaultManager()
  private let prefetchQueue = NSOperationQueue()
  
  private struct memoryCacheImage {
    let image     :UIImage
    var timeStamp :Double
    let url       :NSURL
  }
  
  // memory cache
  
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
    case config.maxMemorySum + 1:
      var old = (0,now)
      for i in 0 ..< memoryCache.count {
        if old.1 < memoryCache[i].timeStamp {
          old = (i,memoryCache[i].timeStamp)
        }
      }
      memoryCache.removeAtIndex(old.0)
      memoryCache.append(memoryCacheImage(image: image, timeStamp:now, url: url))
    default://case: over the limit. because, limit can chenge in runtime.
      for _ in 0 ... 1 {//release cache slowly.
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
  
  //disk cache
  
  
  private func diskCacheRead(url: NSURL) -> UIImage? {
    if let path = PIImageCache.filePath(url, config: config) {
      return UIImage(contentsOfFile: path)
    }
    return nil
  }
  
  private func diskCacheWrite(url:NSURL,image:UIImage) {
    if let path = PIImageCache.filePath(url, config: config) {
      NSData(data: UIImagePNGRepresentation(image)!).writeToFile(path, atomically: true)
    }
  }
  
  //private download
  
  internal enum Result {
    case Mishit, MemoryHit, DiskHit
  }
  
  internal func download(url: NSURL) -> (UIImage, byteSize: Int)? {
    do {
        let maybeImageData = try NSData(contentsOfURL: url, options:NSDataReadingOptions.UncachedRead)
        if let image = UIImage(data: maybeImageData) {
            let bytes = maybeImageData.length
            return (image, bytes)
        }
    } catch {
        print("Error downloading image")
    }
    return nil
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
  
  private func downloadToDisk(url: NSURL) {
    let path = PIImageCache.filePath(url, config: config)
    if path == nil { return }
    if fileManager.fileExistsAtPath(path!) { return }
    let maybeImage = download(url)
    if let (image, byteSize) = maybeImage {
      if byteSize < config.limitByteSize {
        dispatch_semaphore_wait(diskSemaphore, DISPATCH_TIME_FOREVER)
        diskCacheWrite(url, image: image)
        dispatch_semaphore_signal(diskSemaphore)
      }
    }
  }
  
  //util
  
  private var now: Double {
    get {
      return NSDate().timeIntervalSince1970
    }
  }
  
  private func folderCreate() {
    let path = "\(config.cacheRootDirectory)\(config.cacheFolderName)/"
    do {
        try fileManager.createDirectoryAtPath(
            path,
            withIntermediateDirectories: false,
            attributes: nil)
    } catch {
        print("Error creating folder")
    }
  }
  
  private class func filePath(url: NSURL, config:Config) -> String? {
    let urlstr = url.absoluteString
    var code = ""
    for char in urlstr.utf8 {
        code = code + "u\(char)"
    }
    return "\(config.cacheRootDirectory)\(config.cacheFolderName)/\(code)"
  }
  
  private class func folderPath(config: Config) -> String {
    return "\(config.cacheRootDirectory)\(config.cacheFolderName)/"
  }
  
  private func prefetchQueueInit(){
    prefetchQueue.maxConcurrentOperationCount = config.prefetchOprationCount
    if #available(iOS 8.0, *) {
      prefetchQueue.qualityOfService = NSQualityOfService.Background
    }
  }
  
}
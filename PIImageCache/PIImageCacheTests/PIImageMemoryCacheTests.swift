
// https://github.com/pixel-ink/PIImageCache

import UIKit
import XCTest

class PIImageMemoryCacheTests: XCTestCase {
  
  let max = PIImageCache.Config().maxMemorySum
  
  func testDownload() {
    let cache = PIImageCache()
    let url = NSURL(string: "http://place-hold.it/200x200")!
    let (image,dataSize) = cache.download(url)!
    XCTAssert(dataSize == 926 , "Pass")
    XCTAssert(image.size.width == 200 && image.size.height == 200 , "Pass")
  }
  
  func testPerform() {
    let cache = PIImageCache()
    let url = NSURL(string: "http://place-hold.it/200x200")!
    var image: UIImage?, result: PIImageCache.Result
    (image, result) = cache.perform(url)
    XCTAssert(result != .MemoryHit, "Pass")
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    (image, result) = cache.perform(url)
    XCTAssert(result == .MemoryHit, "Pass")
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
  }
  
  func testCacheLimit() {
    let cache = PIImageCache()
    var image: UIImage?, result: PIImageCache.Result
    var urls :[NSURL] = []
    for i in 0 ..< max + 5 {
      urls.append(NSURL(string: "http://place-hold.it/200x200/2ff&text=No.\(i)")!)
    }
    for i in 0 ..< max {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in 0 ..< max {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result == .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in max ..< max + 5 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in 0 ..< max {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in 0 ..< max {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result == .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in max ..< max + 5 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
  }

  func testSharedInstance() {
    let cache1 = PIImageCache.shared
    let cache2 = PIImageCache.shared
    var image: UIImage?, result: PIImageCache.Result
    var urls :[NSURL] = []
    for i in 0 ..< max {
      urls.append(NSURL(string: "http://place-hold.it/200x200/2ff&text=No.\(i)")!)
    }
    for i in 0 ..< max {
      (image, result) = cache1.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in 0 ..< max {
      (image, result) = cache2.perform(urls[i])
      XCTAssert(result == .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
  }
  
  func testCacheMaxCount() {
    let config = PIImageCache.Config()
    config.maxMemorySum = max / 2
    config.limitByteSize = 3 * 1024 * 1024
    let cache = PIImageCache(config: config)
    var image: UIImage?, result: PIImageCache.Result
    var urls :[NSURL] = []
    for i in 0 ..< max {
      urls.append(NSURL(string: "http://place-hold.it/200x200/2ff&text=No.\(i)")!)
    }
    for i in 0 ..< max / 2 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in 0 ..< max / 2 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result == .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in max / 2 ..< max {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
  }

  func testCacheMaxSize() {
    let config = PIImageCache.Config()
    config.usingDiskCache = false
    config.limitByteSize = 100
    let cache = PIImageCache(config: config)
    let url = NSURL(string: "http://place-hold.it/200x200")!
    var image: UIImage?, result: PIImageCache.Result
    (image, result) = cache.perform(url)
    XCTAssert(result != .MemoryHit, "Pass")
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    (image, result) = cache.perform(url)
    XCTAssert(result != .MemoryHit, "Pass")
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
  }
  
  func testSyncGet() {
    let cache = PIImageCache()
    let url = NSURL(string: "http://place-hold.it/200x200")!
    let image = cache.get(url)!
    XCTAssert(image.size.width == 200 && image.size.height == 200 , "Pass")
  }
  
  func testAsyncGet() {
    let cache = PIImageCache()
    let url = NSURL(string: "http://place-hold.it/200x200")!
    cache.get(url) {
      image in
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
  }
  
  func testExtension() {
    let url = NSURL(string: "http://place-hold.it/200x200")!
    let cache = PIImageCache()
    let image = url.getImageWithCache(cache)!
    XCTAssert(image.size.width == 200 && image.size.height == 200 , "Pass")
    let image2 = url.getImageWithCache()!
    XCTAssert(image2.size.width == 200 && image2.size.height == 200 , "Pass")
    var imgView = UIImageView()
    imgView.imageOfURL(url, cache: cache) {
      isOK in
      XCTAssert(imgView.image!.size.width == 200 && imgView.image!.size.height == 200 , "Pass")
      XCTAssert(isOK , "Pass")
    }
    imgView.imageOfURL(url) {
      isOK in
      XCTAssert(imgView.image!.size.width == 200 && imgView.image!.size.height == 200 , "Pass")
      XCTAssert(isOK , "Pass")
    }
  }
  
  func testThreadSafetySyncGet() {
    var urls :[NSURL] = []
    for i in 0 ..< 50 {
      urls.append(NSURL(string: "http://place-hold.it/200x200/2ff&text=No.\(i)")!)
    }
    let cache = PIImageCache()
    for i in 0 ..< 10000 {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        let image = cache.get(urls[i % 50])!
        XCTAssert(image.size.width == 200 && image.size.height == 200 , "Pass")
      }
    }
  }
  
  func testThreadSafetyAsyncGet() {
    var urls :[NSURL] = []
    for i in 0 ..< 50 {
      urls.append(NSURL(string: "http://place-hold.it/200x200/2ff&text=No.\(i)")!)
    }
    let cache = PIImageCache()
    for i in 0 ..< 10000 {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        cache.get(urls[i % 50]) {
          image in
          XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
        }
      }
    }
  }
  
  func testChangeConfigInRunTime() {
    var urls :[NSURL] = []
    for i in 0 ..< 5 {
      urls.append(NSURL(string: "http://place-hold.it/200x200/2ff&text=No.\(i)")!)
    }
    var image: UIImage?, result: PIImageCache.Result
    
    var config = PIImageCache.Config()
    config.usingDiskCache = false
    config.maxMemorySum = 5
    var cache = PIImageCache(config: config)

    for i in 0 ..< 5 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    
    for i in 0 ..< 5 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result == .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }

    config.maxMemorySum = 2
    cache = PIImageCache(config: config)
    
    for i in 0 ..< 2 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    
    for i in 0 ..< 2 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result == .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }

    config.limitByteSize = 100
    cache = PIImageCache(config: config)
    
    for i in 3 ..< 5 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    
    for i in 3 ..< 5 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
  }
  
  func testDeleteMemoryInRuntime () {
    let cache = PIImageCache()
    let url = NSURL(string: "http://place-hold.it/200x200")!
    var image: UIImage?, result: PIImageCache.Result
    (image, result) = cache.perform(url)
    XCTAssert(result != .MemoryHit, "Pass")
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    cache.allMemoryCacheDelete()
    (image, result) = cache.perform(url)
    XCTAssert(result != .MemoryHit, "Pass")
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
  }
  
}

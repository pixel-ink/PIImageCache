
// https://github.com/pixel-ink/PIImageCache

import UIKit
import XCTest

class PIImageMemoryCacheTests: XCTestCase {
  
  let max = PIImageCache.Config().maxMemorySum
  let url = NSURL(string: "http://place-hold.it/200x200")!

  func check(image: UIImage?) {
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
  }
  
  func checkSize(dataSize: Int) {
    XCTAssert(dataSize == 926 , "Pass")
  }
  
  func testDownload() {
    let cache = PIImageCache()
    let (image,dataSize) = cache.download(url)!
    checkSize(dataSize)
    check(image)
  }
  
  func testPerform() {
    let cache = PIImageCache()

    var image: UIImage?, result: PIImageCache.Result
    (image, result) = cache.perform(url)
    XCTAssert(result != .MemoryHit, "Pass")
    check(image)
    (image, result) = cache.perform(url)
    XCTAssert(result == .MemoryHit, "Pass")
    check(image)
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
      check(image)
    }
    for i in 0 ..< max {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result == .MemoryHit, "Pass")
      check(image)
    }
    for i in max ..< max + 5 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      check(image)
    }
    for i in 0 ..< max {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      check(image)
    }
    for i in 0 ..< max {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result == .MemoryHit, "Pass")
      check(image)
    }
    for i in max ..< max + 5 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      check(image)
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
      check(image)
    }
    for i in 0 ..< max {
      (image, result) = cache2.perform(urls[i])
      XCTAssert(result == .MemoryHit, "Pass")
      check(image)
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
      check(image)
    }
    for i in 0 ..< max / 2 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result == .MemoryHit, "Pass")
      check(image)
    }
    for i in max / 2 ..< max {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      check(image)
    }
  }

  func testCacheMaxSize() {
    let config = PIImageCache.Config()
    config.usingDiskCache = false
    config.limitByteSize = 100
    let cache = PIImageCache(config: config)

    var image: UIImage?, result: PIImageCache.Result
    (image, result) = cache.perform(url)
    XCTAssert(result != .MemoryHit, "Pass")
    check(image)
    (image, result) = cache.perform(url)
    XCTAssert(result != .MemoryHit, "Pass")
    check(image)
  }
  
  func testSyncGet() {
    let cache = PIImageCache()

    let image = cache.get(url)!
    XCTAssert(image.size.width == 200 && image.size.height == 200 , "Pass")
  }
  
  func testAsyncGet() {
    let cache = PIImageCache()

    cache.get(url) {
      [weak self] image in
      self?.check(image)
    }
  }
  
  func testExtension() {

    let cache = PIImageCache()
    let image = url.getImageWithCache(cache)!
    check(image)
    let image2 = url.getImageWithCache()!
    check(image2)
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
          [weak self] image in
          self?.check(image)
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
      check(image)
    }
    
    for i in 0 ..< 5 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result == .MemoryHit, "Pass")
      check(image)
    }

    config.maxMemorySum = 2
    cache = PIImageCache(config: config)
    
    for i in 0 ..< 2 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      check(image)
    }
    
    for i in 0 ..< 2 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result == .MemoryHit, "Pass")
      check(image)
    }

    config.limitByteSize = 100
    cache = PIImageCache(config: config)
    
    for i in 3 ..< 5 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      check(image)
    }
    
    for i in 3 ..< 5 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      check(image)
    }
  }
  
  func testDeleteMemoryInRuntime () {
    let cache = PIImageCache()

    var image: UIImage?, result: PIImageCache.Result
    (image, result) = cache.perform(url)
    XCTAssert(result != .MemoryHit, "Pass")
    check(image)
    cache.allMemoryCacheDelete()
    (image, result) = cache.perform(url)
    XCTAssert(result != .MemoryHit, "Pass")
    check(image)
  }
  
}

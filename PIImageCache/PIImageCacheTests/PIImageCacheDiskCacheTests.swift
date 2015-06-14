
// https://github.com/pixel-ink/PIImageCache

import UIKit
import XCTest

class PIImageDiskCacheTests: XCTestCase {
  
  func testDiskCache() {
    let cache = PIImageCache()
    var image: UIImage?, result: PIImageCache.Result
    var urls :[NSURL] = []
    for i in 0 ..< 20 {
      urls.append(NSURL(string: "http://place-hold.it/200x200/2ff&text=No.\(i)")!)
    }
    for i in 0 ..< 20 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .MemoryHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in 0 ..< 20 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result == .DiskHit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
  }
  
  func testFileTimeStamp() {
    PIImageCache.shared.oldDiskCacheDelete()
    let config = PIImageCache.Config()
    let path = "\(config.cacheRootDirectory)\(config.cacheFolderName)/"
    let allFileName: [String]? = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error: nil) as? [String]
    if let all = allFileName {
      for fileName in all {
        if let attr = NSFileManager.defaultManager().attributesOfItemAtPath(path + fileName, error: nil) {
          let diff = NSDate().timeIntervalSinceDate( (attr[NSFileModificationDate] as? NSDate) ?? NSDate(timeIntervalSince1970: 0) )
          XCTAssert( Double(diff) <= Double(config.diskCacheExpireMinutes * 60) , "Pass")
        }
      }
    }
  }
  
  func testPrefetch() {
    let cache = PIImageCache()
    var image: UIImage?, result: PIImageCache.Result
    var urls :[NSURL] = []
    for i in 0 ..< 20 {
      urls.append(NSURL(string: "http://place-hold.it/200x200/2ff&text=BackgroundNo.\(i)")!)
    }
    cache.prefetch(urls)
    for i in 0 ..< 20 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in 0 ..< 20 {
      (image, result) = cache.perform(urls[i])
      XCTAssert(result != .Mishit, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
  }
}

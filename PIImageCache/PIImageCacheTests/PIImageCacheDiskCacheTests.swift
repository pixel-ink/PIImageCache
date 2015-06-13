
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
  
}
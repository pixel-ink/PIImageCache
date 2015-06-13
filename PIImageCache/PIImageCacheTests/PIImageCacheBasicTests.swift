
// https://github.com/pixel-ink/PIImageCache

import UIKit
import XCTest

class PIImageBasicCacheTests: XCTestCase {

  func testREADME() {
    
    //NSURL extension
    let url = NSURL(string: "http://place-hold.it/200x200")!
    var image = url.getImageWithCache()
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")

    //UIImageView extension
    let imgView = UIImageView()
    imgView.imageOfURL(url) {
      isOK in
      XCTAssert(isOK , "Pass")
    }

    //for Background
    var cache = PIImageCache() // or PIImageCache.sherd
    image = cache.get(url)!
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    var config = PIImageCache.Config()
    config.maxCount = 5
    config.maxByteSize = 100 * 1024 // 100kB
    cache.setConfig(config)
    image = cache.get(url)!
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
  }
  
}

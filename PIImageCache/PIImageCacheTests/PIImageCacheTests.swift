//
//  PIImageCacheTests.swift
//  PIImageCacheTests
//
//  Created by Yoshiki Fujiwara on 2015/06/11.
//  Copyright (c) 2015年 pixelink. All rights reserved.
//

import UIKit
import XCTest

class PIImageCacheTests: XCTestCase {

  func testDownload() {
    let cache = PIImageCache()
    let url = NSURL(string: "http://place-hold.it/200x200")!
    let image = cache.download(url)!
    XCTAssert(image.size.width == 200 && image.size.height == 200 , "Pass")
  }
  
}

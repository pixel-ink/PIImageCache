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
    let (image,dataSize) = cache.download(url)!
    XCTAssert(dataSize == 926 , "Pass")
    XCTAssert(image.size.width == 200 && image.size.height == 200 , "Pass")
  }
  
  func testDownloadOrCache() {
    let cache = PIImageCache()
    let url = NSURL(string: "http://place-hold.it/200x200")!
    var image: UIImage?, isCache: Bool
    (image, isCache) = cache.perform(url)
    XCTAssert(isCache == false, "Pass")
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    (image, isCache) = cache.perform(url)
    XCTAssert(isCache == true, "Pass")
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
  }
  
  func testCacheLimit() {
    let cache = PIImageCache()
    var image: UIImage?, isCache: Bool
    var urls :[NSURL] = []
    for i in 0 ..< 15 {
      urls.append(NSURL(string: "http://place-hold.it/200x200/2ff&text=No.\(i)")!)
    }
    for i in 0 ..< 10 {
      (image, isCache) = cache.perform(urls[i])
      XCTAssert(isCache == false, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in 0 ..< 10 {
      (image, isCache) = cache.perform(urls[i])
      XCTAssert(isCache == true, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in 10 ..< 15 {
      (image, isCache) = cache.perform(urls[i])
      XCTAssert(isCache == false, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in 0 ..< 10 {
      (image, isCache) = cache.perform(urls[i])
      XCTAssert(isCache == false, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in 0 ..< 10 {
      (image, isCache) = cache.perform(urls[i])
      XCTAssert(isCache == true, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in 10 ..< 15 {
      (image, isCache) = cache.perform(urls[i])
      XCTAssert(isCache == false, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
  }

  func testSharedInstance() {
    let cache1 = PIImageCache.shared
    let cache2 = PIImageCache.shared
    var image: UIImage?, isCache: Bool
    var urls :[NSURL] = []
    for i in 0 ..< 10 {
      urls.append(NSURL(string: "http://place-hold.it/200x200/2ff&text=No.\(i)")!)
    }
    for i in 0 ..< 10 {
      (image, isCache) = cache1.perform(urls[i])
      XCTAssert(isCache == false, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in 0 ..< 10 {
      (image, isCache) = cache2.perform(urls[i])
      XCTAssert(isCache == true, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
  }
  
  func testCacheMaxCount() {
    let config = PIImageCache.Config()
    config.maxCount = 5
    config.maxByteSize = 3 * 1024 * 1024
    let cache = PIImageCache(config: config)
    var image: UIImage?, isCache: Bool
    var urls :[NSURL] = []
    for i in 0 ..< 10 {
      urls.append(NSURL(string: "http://place-hold.it/200x200/2ff&text=No.\(i)")!)
    }
    for i in 0 ..< 5 {
      (image, isCache) = cache.perform(urls[i])
      XCTAssert(isCache == false, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in 0 ..< 5 {
      (image, isCache) = cache.perform(urls[i])
      XCTAssert(isCache == true, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    for i in 5 ..< 10 {
      (image, isCache) = cache.perform(urls[i])
      XCTAssert(isCache == false, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
  }

  func testCacheMaxSize() {
    let config = PIImageCache.Config()
    config.maxCount = 10
    config.maxByteSize = 100
    let cache = PIImageCache(config: config)
    let url = NSURL(string: "http://place-hold.it/200x200")!
    var image: UIImage?, isCache: Bool
    (image, isCache) = cache.perform(url)
    XCTAssert(isCache == false, "Pass")
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    (image, isCache) = cache.perform(url)
    XCTAssert(isCache == false, "Pass")
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
    var image: UIImage?, isCache: Bool
    
    var config = PIImageCache.Config()
    config.maxCount = 5
    var cache = PIImageCache(config: config)

    for i in 0 ..< 5 {
      (image, isCache) = cache.perform(urls[i])
      XCTAssert(isCache == false, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    
    for i in 0 ..< 5 {
      (image, isCache) = cache.perform(urls[i])
      XCTAssert(isCache == true, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }

    config.maxCount = 2
    cache = PIImageCache(config: config)
    
    for i in 0 ..< 2 {
      (image, isCache) = cache.perform(urls[i])
      XCTAssert(isCache == false, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    
    for i in 0 ..< 2 {
      (image, isCache) = cache.perform(urls[i])
      println(isCache)
      XCTAssert(isCache == true, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }

    config.maxByteSize = 100
    cache = PIImageCache(config: config)
    
    for i in 3 ..< 5 {
      (image, isCache) = cache.perform(urls[i])
      XCTAssert(isCache == false, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
    
    for i in 3 ..< 5 {
      (image, isCache) = cache.perform(urls[i])
      println(isCache)
      XCTAssert(isCache == false, "Pass")
      XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    }
  }

  func testREADME() {
    let url = NSURL(string: "http://place-hold.it/200x200")!
    var image = url.getImageWithCache()
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    let imgView = UIImageView()
    imgView.imageOfURL(url) {
      isOK in
      XCTAssert(isOK , "Pass")
    }
    var cache = PIImageCache()
    image = cache.get(url)!
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
    var config = PIImageCache.Config()
    config.maxCount = 5
    config.maxByteSize = 100
    cache.setConfig(config)
    image = cache.get(url)!
    XCTAssert(image!.size.width == 200 && image!.size.height == 200 , "Pass")
  }
  
}

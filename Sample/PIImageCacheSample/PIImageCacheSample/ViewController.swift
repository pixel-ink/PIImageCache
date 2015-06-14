//
//  ViewController.swift
//  PIImageCacheSample
//
//  Created by Yoshiki Fujiwara on 2015/06/14.
//  Copyright (c) 2015年 pixelink. All rights reserved.
//

import UIKit
import PIImageCache

class ViewController: UIViewController {

  @IBOutlet weak var imgView: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()
    let url = NSURL(string: "http://lorempixel.com/375/667/")!
    imgView.imageOfURL(url)
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    PIImageCache.shared.allMemoryCacheDelete()
  }


}


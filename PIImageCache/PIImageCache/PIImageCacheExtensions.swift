
// https://github.com/pixel-ink/PIImageCache

import UIKit

public extension NSURL {
  public func getImageWithCache() -> UIImage? {
    return PIImageCache.shared.get(self)
  }
  
  public func getImageWithCache(cache: PIImageCache) -> UIImage? {
    return cache.get(self)
  }
}

public extension UIImageView {
  public func imageOfURL(url: NSURL) {
    PIImageCache.shared.get(url) {
      [weak self] img in
      self?.image = img
    }
  }
  
  public func imageOfURL(url: NSURL, cache: PIImageCache) {
    cache.get(url) {
      [weak self] img in
      self?.image = img
    }
  }
  
  public func imageOfURL(url: NSURL, then:(Bool)->Void) {
    PIImageCache.shared.get(url) {
      [weak self] img in
      let isOK = img != nil
      self?.image = img
      then(isOK)
    }
  }
  
  public func imageOfURL(url: NSURL, cache: PIImageCache, then:(Bool)->Void) {
    cache.get(url) {
      [weak self] img in
      let isOK = img != nil
      self?.image = img
      then(isOK)
    }
  }
}

# Working now.

---

# PIImageCache

## NSURL -> UIImage with cache (swift)

![](https://cocoapod-badges.herokuapp.com/l/PIImageCache/badge.png)
![](https://cocoapod-badges.herokuapp.com/v/PIImageCache/badge.png)
![](https://cocoapod-badges.herokuapp.com/p/PIImageCache/badge.png)

---


# install

### step1

- manually
  - add PIImageCache.swift into your project
- cocoapods
  - add " pod 'PIImageCache', '0.1.1' " into your Podfile
  - add " import PIImageCache " into your code

### step2

- add this into your ViewController

```
override func didReceiveMemoryWarning() {
  cache.allMemoryCacheDelete()
}
```

### step3

- add this into your AppDelegate

```
func applicationDidEnterBackground(application: UIApplication) {
  PIImageCache.shared.oldDiskCacheDelete()
}
```

# basic usage

## NSURL extension

```NSURL.swift
let url = NSURL(string: "http://place-hold.it/200x200")!
let image = url.getImageWithCache()
```

## UIImageView extension

```UIImageView.swift
let url = NSURL(string: "http://place-hold.it/200x200")!
let imgView = UIImageView()
imgView.imageOfURL(url)
```

## for background

```PIImageCache.swift
let url = NSURL(string: "http://place-hold.it/200x200")!
let cache = PIImageCache.shared
image = cache.get(url)!
```

# advanced usage

## configurable

```Config.swift
let cache = PIImageCache.shared
var config = PIImageCache.Config()
config.maxMemorySum = 5
config.limitByteSize = 100 * 1024 // 100kB
cache.setConfig(config)

let url = NSURL(string: "http://place-hold.it/200x200")!
let image = cache.get(url)!
```

- default values
  - maxMemorySum           = 10 // 10 images
  - limitByteSize          = 3 * 1024 * 1024 //3MB
  - usingDiskCache         = true
  - diskCacheExpireMinutes = 24 * 60 // 1 day
  - cacheRootDirectory     = NSTemporaryDirectory()
  - cacheFolderName        = "PIImageCache"
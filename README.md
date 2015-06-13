
# Working now.

---

# PIImageCache

## NSURL -> UIImage with cache (swift)

![](https://cocoapod-badges.herokuapp.com/l/PIImageCache/badge.png)
![](https://cocoapod-badges.herokuapp.com/v/PIImageCache/badge.png)
![](https://cocoapod-badges.herokuapp.com/p/PIImageCache/badge.png)

---


# install

- manually
  - add PIImageCache.swift into your project
- cocoapods
  - add " pod 'PIImageCache', '0.1.1' " into your Podfile
  - add " import PIImageCache " into your code

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
config.maxCount = 5
config.maxByteSize = 100
cache.setConfig(config)

let url = NSURL(string: "http://place-hold.it/200x200")!
let image = cache.get(url)!
```
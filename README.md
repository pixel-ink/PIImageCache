
# Working now.

---

# PIImageCache

## NSURL -> UIImage with cache (swift)

![](https://cocoapod-badges.herokuapp.com/l/PIRipple/badge.png)
![](https://cocoapod-badges.herokuapp.com/p/PIRipple/badge.png)

---

# install

- manually
  - add PIImageCache.swift into your project

# usage

- create cache instance
- get image by NSURL extension

# example

```
  let url = NSURL(string: "http://place-hold.it/200x200")!
  let cache = PIImageCache()
  url.getImageWithCache(cache)
```

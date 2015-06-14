Pod::Spec.new do |s|

  s.name                   = "PIImageCache"
  s.version                = "1.0.0"
  s.summary                = "An asynchronous image downloader, with memory + disk caching."
  s.homepage               = "https://github.com/pixel-ink/PIImageCache"
  s.license                = { :type => "MIT", :file => "LICENSE" }
  s.author                 = { "pixelink" => "https://github.com/pixel-ink" }
  s.social_media_url       = "http://twitter.com/pixelink_jp"
  s.ios.deployment_target  = "8.0"
  s.source                 = {
                               :git => "https://github.com/pixel-ink/PIImageCache.git",
                               :tag => s.version
                             }
  s.source_files           = "**/PIImageCache/PIImageCache*.swift"

end
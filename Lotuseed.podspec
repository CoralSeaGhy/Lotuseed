Pod::Spec.new do |s|
  s.name         = "Lotuseed"
  s.version      = "0.0.1"
  s.summary      = "A short description of Lotuseed."
  s.homepage     = "https://github.com/CoralSeaGhy/Lotuseed"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "CoralSeaGhy" => "15136166637@163.com" }
  s.source       = { :git => "https://github.com/CoralSeaGhy/Lotuseed.git", :tag => “0.01”}
  s.source_files  = “Lotuseed/*.{h,m}”
  s.platform     = :ios
  s.frameworks = “SystemConfiguration”, “Security”
  s.library   = “libz”
  s.requires_arc = false

end

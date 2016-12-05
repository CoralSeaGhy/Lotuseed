Pod::Spec.new do |s|
  s.name         = "Lotuseed"
  s.version      = '1.1.3'
  s.summary      = "Third-party data sources can be docked and reporting systems."
  s.homepage     = 'https://github.com/CoralSeaGhy/Lotuseed'
  s.license      = 'MIT'
  s.author       = { 'CoralSeaGhy' => '15136166637@163.com' }
  s.source       = { :git => "https://github.com/CoralSeaGhy/Lotuseed.git", :tag => s.version.to_s }
  s.source_files  = 'Lotuseed/*'
  s.ios.vendored_library = 'Lotuseed/Resources/libLotuseed.a'
  s.public_header_files = 'Lotuseed/*.h'
  s.platform     = :ios, '4.3'
  s.frameworks = 'SystemConfiguration', 'Security'
  s.requires_arc = false
end

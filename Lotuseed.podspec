Pod::Spec.new do |s|
  s.name         = "Lotuseed"
  s.version      = '1.2.6'
  s.summary      = "Third-party data sources can be docked and reporting systems."
  s.homepage     = 'https://github.com/CoralSeaGhy/Lotuseed'
  s.license      = 'MIT'
  s.author       = { 'CoralSeaGhy' => '15136166637@163.com' }
  s.source       = { :git => "https://github.com/CoralSeaGhy/Lotuseed.git", :tag => s.version.to_s }
  s.source_files  = 'Lotuseed/*.h'
  s.vendored_libraries = 'Lotuseed/libLotuseed.a'
  s.public_header_files = 'Lotuseed/Lotuseed.h'
  s.platform     = :ios, '4.3'
  s.frameworks = 'SystemConfiguration', 'Security'
  s.pod_target_xcconfig = {'OTHER_LDFLAGS' => '-lObjC'}
  s.requires_arc = false 
end

Pod::Spec.new do |s|
  s.name         = "Lotuseed"
  s.version      = '0.0.8'
  s.summary      = "Third-party data sources can be docked and reporting systems."
  s.homepage     = 'https://github.com/CoralSeaGhy/Lotuseed'
  s.license      = 'MIT'
  s.author       = { 'CoralSeaGhy' => '15136166637@163.com' }
  s.source       = { :git => "https://github.com/CoralSeaGhy/Lotuseed.git", :tag => s.version.to_s }
  s.source_files  = 'Lotuseed/*'
  s.platform     = :ios, '4.3'
  s.frameworks = 'SystemConfiguration', 'Security'
  s.requires_arc = false
end

Pod::Spec.new do |s|
  s.name         = "Lotuseed"
  s.version      = ‘0.0.3’
  s.summary      = "The whole process automated visualization, custom KPI dashboards, and business data system flexible docking, third-party data sources can be docked and reporting systems."
  s.homepage     = 'https://github.com/CoralSeaGhy/Lotuseed'
  s.license      = 'MIT'
  s.author             = { "CoralSeaGhy" => '15136166637@163.com' }
  s.source       = { :git => "https://github.com/CoralSeaGhy/Lotuseed.git", :tag => 0.0.3}
  s.source_files  = 'Lotuseed/*'
  s.platform     = :ios, '4.3'
  s.frameworks = 'SystemConfiguration', 'Security'
  s.library   = 'libz'
  s.requires_arc = false
end

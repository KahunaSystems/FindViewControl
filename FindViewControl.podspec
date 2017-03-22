Pod::Spec.new do |s|

  s.name         = "FindViewControl"
  s.version      = "1.0.12"
  s.summary      = "FindViewControl for Find implementation"
  s.description  = "FindViewControl for plotting nearby places based on location"
  s.homepage     = "https://github.com/Kruks/FindViewControl/blob/master/README.md"
  s.license      = "MIT"
  s.author             = "Kahuna"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Kruks/FindViewControl.git", :tag => "#{s.version}" }
  s.source_files  = "FindViewControl", "FindViewControl/**/*.{h,m,swift,xib,png,strings}"
s.requires_arc = true
s.dependency 'MFSideMenu'
  s.dependency 'MBProgressHUD', '~> 0.9.2'
  s.dependency 'Alamofire', '~> 4.3'
  s.dependency 'GoogleMaps'
  s.dependency 'SQLite.swift', '~> 0.11.2'
s.pod_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/GoogleMaps',
    'OTHER_LDFLAGS' => '$(inherited) -undefined dynamic_lookup -ObjC'
}
end


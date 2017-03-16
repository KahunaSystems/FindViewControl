Pod::Spec.new do |s|

  s.name         = "FindViewControl"
  s.version      = "1.0.0"
  s.summary      = "FindViewControl."
  s.description  = "FindViewControl for plotting places"
  s.homepage     = "https://github.com/"
  s.license      = "MIT"
  s.author             = "Kahuna"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Kruks/FindViewControl.git", :tag => “1.0.1” }
  s.source_files  = "FindViewControl", "FindViewControl/**/*.{h,m,swift}"
s.requires_arc = true
s.dependency 'MFSideMenu'
  s.dependency 'MBProgressHUD', '~> 0.9.2'
  s.dependency 'Alamofire', '~> 4.3'
end


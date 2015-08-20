Pod::Spec.new do |s|
  s.name         = "BWWalkthrough"
  s.version      = "0.6.1"
  s.summary      = "BWWalkthrough is a class to build custom walkthroughs for your iOS App"
  s.homepage     = "https://github.com/ariok/BWWalkthrough.git"
  s.screenshots  = "https://camo.githubusercontent.com/da60dc338f1325ad6f317e850d79ec135e64b116/687474703a2f2f7777772e7468696e6b616e646275696c642e69742f676966732f425757616c6b7468726f7567685f6d696e69322e676966"
  s.license      = { :type => "MIT", :file => "LICENSE.txt" }
  s.author             = { "Yari D'areglia" => "" }
  s.social_media_url   = "http://twitter.com/bitwaker"
  s.platform     = :ios
  s.ios.deployment_target	= '8.0'
  s.source       = { :git => "https://github.com/ariok/BWWalkthrough.git", :tag => "0.6.1" }
  s.source_files  = "BWWalkthrough/*.swift"
  s.frameworks   = ['Foundation', 'UIKit']
  s.requires_arc = true
end

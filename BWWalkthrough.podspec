Pod::Spec.new do |s|
  s.name             = "BWWalkthrough"
  s.version          = "1.1.0"
  s.summary          = "Generate custom walkthroughs for your apps."
  s.description      = "BWWalkthrough (BWWT) is a class that helps you create Walkthroughs for your iOS Apps. It differs from other similar classes in that there is no rigid template; rigid template; BWWT is just a layer placed over your controllers that gives you complete freedom on the design of your views"
  s.homepage         = "https://github.com/ariok/BWWalkthrough"
  s.license          = 'MIT'
  s.author           = { "Yari D\'areglia" => "dareglia@gmail.com" }
  s.source           = { :git => "https://github.com/ariok/BWWalkthrough.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bitwaker'
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'BWWalkthrough' => ['Pod/Assets/*.png']
  }
  s.frameworks   = ['Foundation', 'UIKit']
end

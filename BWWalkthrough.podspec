Pod::Spec.new do |s|
  s.name             = "BWWalkthrough"
  s.version          = "1.2.1"
  s.summary          = "Generate custom walkthroughs for your apps."
  s.homepage         = "https://github.com/ariok/BWWalkthrough"
  s.license          = 'MIT'
  s.author           = { "Yari D\'areglia" => "dareglia@gmail.com" }
  s.source           = { :git => "https://github.com/ariok/BWWalkthrough.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bitwaker'
  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'BWWalkthrough' => ['Pod/Assets/*.png']
  }
end

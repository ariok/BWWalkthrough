Pod::Spec.new do |spec|
  spec.name = 'BWWalkthrough'
  spec.version = '2.1.1'
  spec.summary = 'BWWalkthrough is a class to build custom walkthroughs for your iOS App'
  spec.homepage = 'https://github.com/ariok/bwwalkthrough'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'Yari Dareglia' => 'dareglia@gmail.com' }
  spec.social_media_url = 'http://twitter.com/bitwaker'
  spec.source = { :git => 'https://github.com/ariok/BWWalkthrough.git', :tag => "#{spec.version}" }
  spec.source_files = 'BWWalkthrough/*.swift'
  spec.ios.deployment_target = '9.0'
  spec.requires_arc = true
  spec.module_name = 'BWWalkthrough'
end

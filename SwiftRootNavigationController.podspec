#
# Be sure to run `pod lib lint SwiftRootNavigationController.podspec' to ensure this is a
# valid spec before submitting.
Pod::Spec.new do |s|
  s.name             = 'SwiftRootNavigationController'
  s.version          = '0.1.2'
  s.summary          = 'Implicitly make every view controller has its own navigation bar'
  s.description      = <<-DESC
  Implicitly make every view controller has its own navigation bar. A swift version of RTRootNavigationController.
                       DESC
  s.homepage         = 'https://github.com/gewill/SwiftRootNavigationController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ge Will' => '531sunlight@gmail.com' }
  s.source           = { :git => 'https://github.com/gewill/SwiftRootNavigationController.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/BoJack_D'
  
  s.swift_version = '5.0'
  s.ios.deployment_target = '9.0'
  s.source_files = 'SwiftRootNavigationController/Classes/**/*'
end

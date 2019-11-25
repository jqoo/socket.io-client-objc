#
# Be sure to run `pod lib lint socket.io-client-objc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'socket.io-client-objc'
  s.version          = '0.1.0'
  s.summary          = 'A short description of socket.io-client-objc.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/MDoEEPgAAAAAAAAAAAAAAAAAAAEwFAYIKoZIhvcNAwcECPVhY6001vdcBBA0CNPkkJoG3K+DKSynV74R/socket.io-client-objc'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'MDoEEPgAAAAAAAAAAAAAAAAAAAEwFAYIKoZIhvcNAwcECPVhY6001vdcBBA0CNPkkJoG3K+DKSynV74R' => 'jinquanzhang@blackfish.cn' }
  s.source           = { :git => 'https://github.com/MDoEEPgAAAAAAAAAAAAAAAAAAAEwFAYIKoZIhvcNAwcECPVhY6001vdcBBA0CNPkkJoG3K+DKSynV74R/socket.io-client-objc.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.libraries = 'c++'
  s.source_files = 'socket.io-client-objc/Classes/**/*'
  s.vendored_libraries = 'socket.io-client-objc/lib/**/*.a'

  # s.resource_bundles = {
  #   'socket.io-client-objc' => ['socket.io-client-objc/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

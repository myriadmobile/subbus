#
# Be sure to run `pod lib lint Subbus.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Subbus'
  s.version          = '0.1.0'
  s.summary          = 'Subbus is a library that improves upon NSNotificationCenter.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Subbus is a library that improves upon NSNotificationCenter. You specify objects that are passed as events and the library automatically defines a message name. This means that you, as a developer, don't have to worry about remember what the s of your various subscriptions are.
                       DESC

  s.homepage         = 'https://github.com/myriadmobile/subbus'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alex Larson' => 'alarson@myriadmobile.com' }
  s.source           = { :git => 'https://github.com/myriadmobile/subbus.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'Subbus/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Subbus' => ['Subbus/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

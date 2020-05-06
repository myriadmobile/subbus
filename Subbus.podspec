#
# Be sure to run `pod lib lint Subbus.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Subbus'
  s.version          = '2.0.0'
  s.summary          = 'Subbus is a notification library similar to NotificationCenter.'

  s.description      = <<-DESC
Subbus is a notification library similar to NotificationCenter

You specify objects that are passed as events and the library automatically defines a message name. This means that you, as a developer, don't have to worry about remember what the s of your various subscriptions are.

Subbus can also post persisted events, meaning subscribers will receive past events upon registering.
                       DESC

  s.homepage         = 'https://github.com/myriadmobile/subbus'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alex Larson' => 'alarson@myriadmobile.com' }
  s.source           = { :git => 'https://github.com/myriadmobile/subbus.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_version = '4.0'

  s.source_files = 'Subbus/Classes/**/*'
  
end

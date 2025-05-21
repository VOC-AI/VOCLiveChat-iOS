#
# Be sure to run `pod lib lint VocLiveChatFramework.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VocLiveChatFramework'
  s.version          = '1.3.2'
  s.summary          = 'VOC AI LiveChat iOS SDK'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
VOC AI LiveChat iOS SDK
                       DESC

  s.homepage         = 'https://github.com/VOC-AI/VOCLiveChat-iOS.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Your Name' => 'anti2moron@gmail.com' }
  s.source           = { :git => 'git@github.com:VOC-AI/VOCLiveChat-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'VocLiveChatFramework/Classes/**/*'
  
  s.resource_bundles = {
    'VocLiveChatFramework' => ['VocLiveChatFramework/Assets/*']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

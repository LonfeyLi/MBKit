#
# Be sure to run `pod lib lint MBKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'MBKit'
s.version          = '0.3.0'
s.summary          = 'A collection of iOS components in our project.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = <<-DESC
TODO: 我们公司项目用到的iOS工具类合集.
DESC

s.homepage         = 'https://github.com/LoneyLi/MBKit'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'LoneyLi' => 'lufei@maltbaby.com.cn' }
s.source           = { :git => 'https://github.com/LoneyLi/MBKit.git', :tag => s.version.to_s }

s.ios.deployment_target = '9.0'
s.requires_arc = true
s.source_files = 'MBKit/Classes/MBNetworkRecorder/**/*{.h,.m,.mm}'
# s.resource_bundles = {
#   'MBKit' => ['MBKit/Assets/*.png']
# }

# s.public_header_files = 'Pod/Classes/**/*.h'
# s.frameworks = 'UIKit', 'MapKit'
s.dependency 'DoraemonKit/Core'
s.dependency 'Masonry'
end

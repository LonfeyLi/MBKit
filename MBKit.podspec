#
# Be sure to run `pod lib lint MBKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'MBKit'
s.version          = '1.0.0'
s.summary          = 'A collection of iOS components in our project.'
s.description      = <<-DESC
TODO: 我们公司项目用到的iOS工具类合集.
DESC

s.homepage         = 'https://github.com/LonfeyLi/MBKit'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'LonfeyLi' => 'lufei@maltbaby.com.cn' }
s.source           = { :git => 'https://github.com/LonfeyLi/MBKit.git', :tag => s.version.to_s }
#s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
s.ios.deployment_target = '9.0'
s.requires_arc = true
s.source_files = 'MBKit/Classes/**/*{.h,.m}'
s.dependency 'DoraemonKit/Core'
s.dependency 'Masonry'
end

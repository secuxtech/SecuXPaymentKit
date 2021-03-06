#
# Be sure to run `pod lib lint SecuXPaymentKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SecuXPaymentKit'
  s.version          = '0.0.4'
  s.summary          = 'SecuX Payment SDK amd sample.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/secuxtech/SecuXPaymentKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'SecuX' => 'maochunsun@secuxtech.com' }
  s.source           = { :git => 'https://github.com/secuxtech/SecuXPaymentKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'SecuXPaymentKit/Classes/**/*'
  #s.vendored_frameworks = 'SPManager.framework'
  
  # s.resource_bundles = {
  #   'SecuXPaymentKit' => ['SecuXPaymentKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  #s.dependency 'AFNetworking', '~> 2.3'
  
  s.static_framework = true
  s.dependency 'SPManager'
  #s.dependency 'SecuXMaochunTest'
end

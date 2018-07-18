#
# Be sure to run `pod lib lint GPS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GPS'
  s.version          = '0.1.2'
  s.summary          = 'GPS provides an library for performing essential offline tasks involving GPS coordinates and earthly triginometric formulas.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
GPS provides an API for performing essential offline tasks involving GPS coordinates and earthly triginometric formulas. GPS provides formulas for distances, day durations, sunrise sunset, distance to horizon and more.
                       DESC

  s.homepage         = 'https://github.com/arr00/GPS-pod'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'arr00' => 'aryeh@aryehgreenberg.com' }
  s.source           = { :git => 'https://github.com/arr00/GPS-pod.git', :tag => s.version.to_s }
  s.swift_version = '3.0'
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'GPS/Classes/**/*'
  
  # s.resource_bundles = {
  #   'GPS' => ['GPS/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'CoreLocation'
  # s.dependency 'AFNetworking', '~> 2.3'
end

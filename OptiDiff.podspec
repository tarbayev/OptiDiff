#
# Be sure to run `pod lib lint OptiDiff.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OptiDiff'
  s.version          = '0.2.0'
  s.summary          = 'A library for fast calculating of optimal collection diffs.'

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A library for calculating optimal collection diffs using an LIS-based algorithm with less than **O(n log₂ n)** worst case total time (approximately  **n log₂ n − n log₂log₂ n + O(n)**).
  The result diff is a minimal required diff equivalent to the result of Myers algorithm (which has **O(n²)** complexity) used in Swift standard library.
  DESC

  s.homepage         = 'https://github.com/tarbayev/OptiDiff'
  s.license          = { :type => 'Unlicense', :file => 'LICENSE.md' }
  s.author           = { 'Nickolay Tarbayev' => 'tarbayev-n@yandex.ru' }
  s.source           = { :git => 'https://github.com/tarbayev/OptiDiff.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '11.0'
  s.swift_versions = '5.3'

  s.subspec 'Diff' do |spec|
    spec.source_files = 'Sources/Diff/**/*.swift'
  end

  s.subspec 'UI' do |spec|
    spec.source_files = 'Sources/UI/**/*.swift'
    spec.dependency 'OptiDiff/Diff'
    spec.framework = 'UIKit'
  end

  s.test_spec 'Tests' do |spec|
    spec.source_files = 'Tests/*.swift'
  end

  s.test_spec 'UITests' do |spec|
    spec.source_files = 'UITests/*.swift'
    spec.requires_app_host = true
    spec.app_host_name = 'OptiDiff/ExampleApp'
    spec.test_type = :ui
    spec.dependency 'OptiDiff/ExampleApp'
  end

  s.app_spec 'ExampleApp' do |spec|
    spec.source_files = 'ExampleApp/*.swift'
    spec.resources = [ 'ExampleApp/*.storyboard' ]
    spec.info_plist = {
      'UIMainStoryboardFile' => 'Main'
    }
  end
end

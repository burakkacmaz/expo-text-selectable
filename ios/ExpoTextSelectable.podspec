require 'json'

package = JSON.parse(File.read(File.join(__dir__, '..', 'package.json')))

Pod::Spec.new do |s|
  s.name = 'ExpoTextSelectable'
  s.version = package['version']
  s.summary = package['description']
  s.description = s.summary
  s.license = package['license']
  s.author = package['author']
  s.homepage = 'https://github.com/burakkacmaz/expo-text-selectable'
  s.platforms = { :ios => '16.4' }
  s.source = { :git => 'https://github.com/burakkacmaz/expo-text-selectable.git', :tag => "v#{s.version}" }
  s.static_framework = true
  s.dependency 'ExpoModulesCore'
  s.source_files = '**/*.swift'
end

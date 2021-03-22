# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/mimikgit/cocoapod-edge-specs.git'

target 'example-dev-id-token' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for example_microservice_app
  pod 'MIMIKEdgeMobileClient', '6.2.1'
  pod 'RxSwift', '6.1.0'

  # ignore all warnings from all pods
  inhibit_all_warnings!
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['ENABLE_BITCODE'] = 'YES'
              config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
              config.build_settings['VALID_ARCHS'] = '$(ARCHS_STANDARD_64_BIT)'
              config.build_settings['SWIFT_VERSION'] = '5.3'
          end
      end
  end
end

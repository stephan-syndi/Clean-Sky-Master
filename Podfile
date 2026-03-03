project 'Clean-Sky Master.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'Clean-Sky Master' do
  use_frameworks!
  pod 'Alamofire', '~> 5.9'
  pod 'AppsFlyerFramework', '= 6.12'
  pod 'Firebase/Core', '12.7.0'
  pod 'Firebase/Messaging', '12.7.0'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end

target 'notifications' do
  use_frameworks!
  
  pod 'Alamofire', '~> 5.9'
  pod 'AppsFlyerFramework', '= 6.12'
  pod 'Firebase/Core', '12.7.0'
  pod 'Firebase/Messaging', '12.7.0'
  
end

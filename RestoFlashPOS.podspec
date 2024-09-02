Pod::Spec.new do |spec|
  spec.name         = "RestoFlashPOS"
  spec.version      = "1.0.0"
  spec.summary      = "Resto Flash payment integration for Points of Sale"
  spec.homepage     = "https://www.restoflash.fr"
  spec.author       = { "Alexis Contour" => "alexis.contour@gmail.com" }
  spec.source       = { :git => "https://github.com/Restoflash/RestoFlashPOS.git", :tag => "#{spec.version}" }
  spec.ios.deployment_target = '13.0'
  spec.source_files  = "Sources/**/*.{h,m,swift}"
  spec.exclude_files = "Tests/**/*.*"
  spec.resources = 'Resources/**/*'

  spec.dependency 'Money-FlightSchool', '~> 1.0'
  spec.dependency 'Eureka', '~> 5.0'
  spec.dependency 'Disk', '~> 0.6.4'
  spec.dependency 'SwiftDate', '~> 7.0'
  spec.dependency 'ProgressHUD', '~> 14.1'

  spec.static_framework = true
  spec.swift_version = '5.0'
end


Pod::Spec.new do |s|
  s.name             = 'AKSubscription'
  s.version          = '1.0.0'
  s.summary          = 'Making purchase of subscription more easy hassle Free via AppKitSubscriptions'
  s.description      = <<-DESC
    A short description of AKSubscription.
    This library simplifies handling subscriptions in iOS using StoreKit.
  DESC
  s.homepage         = 'https://github.com/Shrejas/AKSubscriptions.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Shrejash Chandel' => 'idevshrejash@gmail.com' }
  s.source           = { :git => 'https://github.com/Shrejas/AKSubscriptions.git', :tag => '1.0.0' }

  s.platform         = :ios, '17.0'
  s.swift_versions   = ['5.5', '5.6', '5.7', '5.8', '5.9']
  s.source_files     = 'AKSubscription/**/*.{swift}'
  s.frameworks       = ['SwiftUI', 'Foundation']
  s.requires_arc     = true
end








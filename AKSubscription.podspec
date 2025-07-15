Pod::Spec.new do |s|
  s.name             = 'AKSubscription'
  s.version          = '1.1.6'
  s.summary          = 'Making purchase of subscription more easy hassle Free via AppKitSubscriptions'
  s.description      = <<-DESC
    AKSubscription is a comprehensive iOS library that simplifies in-app subscription handling using StoreKit.
    It provides easy-to-use interfaces for managing different types of subscriptions including:
    * Consumable purchases
    * Non-consumable purchases
    * Auto-renewable subscriptions
    * Non-renewing subscriptions
    
    The library handles all the complexity of StoreKit integration, receipt validation,
    and subscription status management.
  DESC
  s.homepage         = 'https://github.com/Shrejas/AKSubscriptions.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Shrejash Chandel' => 'idevshrejash@gmail.com' }
  s.source           = { :git => 'https://github.com/Shrejas/AKSubscriptions.git', :tag => '1.1.6' }

  s.platform         = :ios, '15.0'
  s.swift_versions   = ['5.5', '5.6', '5.7', '5.8', '5.9']
  s.source_files = ['AKSubscription/**/*.{swift}', 'AppStoreEnvironment.swift', 'StoreError.swift', 'SubscriptionPayload.swift', 'SubscriptionFetchResult.swift','IAPConstants.swift']
  s.frameworks       = ['SwiftUI', 'Foundation']
  s.requires_arc     = true
end








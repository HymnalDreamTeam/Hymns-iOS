# Uncomment the next line to define a global platform for your project
platform :ios, '14.4'

target 'Hymns' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Hymns
  
  #Needed for Realm database 
  pod 'RealmSwift'
  
  # Tool to enforce Swift style and conventions.
  # https://realm.github.io/SwiftLint
  pod 'SwiftLint'
  
  # Dependency Injection Framework
  # https://github.com/hmlongco/Resolver
  pod 'Resolver'

  # add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'
  # add pods for any other desired Firebase products
  # https://firebase.google.com/docs/ios/setup#available-pods

  # Crash reporting
  pod 'Firebase/Crashlytics'

  # Facebook SDK
  pod 'FacebookCore'

  pod 'lottie-ios'

  # SQLite wrapper
  pod 'GRDB.swift'
  pod 'GRDBCombine'

  pod 'SwiftUIPager'
  pod 'SwiftEventBus'

  target 'HymnsTests' do
    inherit! :search_paths
    
    # Mocking framework
    # https://github.com/birdrides/mockingbird
    pod 'MockingbirdFramework'

    # Quick & Nimble
    # https://github.com/Quick/Quick
    pod 'Quick'
    # https://github.com/Quick/Nimble
    pod 'Nimble'
  end

  target 'HymnsSnapshotTests' do
    # Pods for Snapshot tests

    # https://github.com/pointfreeco/swift-snapshot-testing
    # https://www.vadimbulavin.com/snapshot-testing-swiftui-views/
    pod 'SnapshotTesting'
  end

  target 'HymnsUITests' do
    # Pods for testing
  end
end

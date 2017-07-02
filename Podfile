use_frameworks!
inhibit_all_warnings!
platform :osx, "10.11"
workspace "BitBar.xcworkspace"

target "Packages" do
  use_frameworks!
  project "Packages/Packages.xcodeproj"

  target "BitBar" do
    use_frameworks!
    inherit! :search_paths
    project "BitBar.xcodeproj"

    pod "Hue"
    pod "ReSwift"
    pod "SwiftyBeaver"
    pod "SwiftyUserDefaults"
    pod "Alamofire"
    pod "Sparkle"
    pod "AlamofireImage"
    pod "AsyncSwift"
    pod "Cent"
    pod "BonMot"
    pod "OcticonsSwift"
    pod "Ansi"
    pod "Dollar"
    pod "Emojize"
    pod "PathKit"
    pod "FootlessParser", git: "https://github.com/oleander/FootlessParser.git"
    pod "DateToolsSwift", git: "https://github.com/MatthewYork/DateTools.git"

    target "BitBarTests" do
      inherit! :search_paths
      pod "Nimble"
      pod "Quick"
    end
  end
end

target "Config" do
  use_frameworks!
  project "BitBar.xcodeproj"

  pod "PathKit"
  pod "Toml", git: "https://github.com/oleander/swift-toml.git"
  pod "FootlessParser", git: "https://github.com/oleander/FootlessParser.git"

  target "ConfigTests" do
    use_frameworks!
    inherit! :search_paths
    pod "Nimble"
    pod "Quick"
  end

  target "Plugin" do
    use_frameworks!
    inherit! :search_paths
    project "BitBar.xcodeproj"

    pod "SwiftyTimer"
    pod "PathKit"
    pod "SwiftyBeaver"
    pod "DateToolsSwift", git: "https://github.com/MatthewYork/DateTools.git"
    pod "Script", git: "https://github.com/oleander/Script.git"
    pod "Parser", git: "https://github.com/oleander/BitBarParser.git"
    pod "FootlessParser", git: "https://github.com/oleander/FootlessParser.git"
    pod "AsyncSwift"
    pod "Cent"
    pod "Dollar"

    target "PluginTests" do
      inherit! :search_paths
      pod "Nimble"
      pod "Quick"
    end
  end
end

pre_install do
  system "make prebuild_vapor symlink_vapor"
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ""
    end
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
    end
  end

  installer.pods_project.build_configurations.each do |config|
    config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = [
      '$(FRAMEWORK_SEARCH_PATHS)'
    ]
  end
end


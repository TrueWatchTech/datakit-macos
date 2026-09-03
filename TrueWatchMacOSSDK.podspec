Pod::Spec.new do |spec|

  spec.name         = "TrueWatchMacOSSDK"
  # spec.version      = "1.0.0-alpha.1"
  spec.version      = "$JENKINS_DYNAMIC_VERSION"
  spec.summary      = "TrueWatchTech macOS Data Collection SDK"
  # spec.description  = ""

  spec.homepage     = "https://github.com/TrueWatchTech/datakit-macos"

  spec.license      = { type: "Apache", :file => "LICENSE" }
  spec.user_target_xcconfig = { "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" => "YES" }

  spec.author       = {
    "hulilei" => "huuuu1016@gmail.com",
    "BrandonZhang" => "brandonzhangdev@gmail.com"
  }

  spec.osx.deployment_target = "10.13"
  spec.requires_arc = true

  spec.source       = {
    :git => "https://github.com/TrueWatchTech/datakit-macos.git",
    :tag => "$JENKINS_DYNAMIC_VERSION"
  }

  spec.default_subspec = "SDKCore"

  spec.subspec "SDKCore" do |core|
    core.source_files = "FTMacOSSDK/SDKCore/**/*.{h,m}"
    core.dependency "TrueWatchMobileSDK/FTSDKCore", "1.4.9-alpha.1"
  end

end

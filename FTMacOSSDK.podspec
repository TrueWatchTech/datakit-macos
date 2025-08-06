
Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "FTMacOSSDK"
#   spec.version      = "1.0.0-alpha.1"
  spec.version      = "$JENKINS_DYNAMIC_VERSION"
  spec.summary      = "TrueWatchTech macOS Data Collection SDK"
  #spec.description  = ""

  spec.homepage     = "https://github.com/TrueWatchTech/datakit-macos"

  spec.license      = { type: 'Apache', :file => 'LICENSE'}
  spec.user_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }

  spec.author             = { "hulilei" => "hulilei@jiagouyun.com","BrandonZhang"=> "zhangbo@jiagouyun.com" }
 
  spec.osx.deployment_target = '10.13'
  spec.requires_arc = true
  
  spec.source       = { :git => "https://github.com/TrueWatchTech/datakit-macos.git", :tag => "$JENKINS_DYNAMIC_VERSION" }

  spec.default_subspec = "SDKCore"

  spec.subspec 'SDKCore' do |core|
       core.source_files  = "FTMacOSSDK/SDKCore/**/*.{h,m}"
       core.dependency 'FTMobileSDK/FTSDKCore', '1.4.9-alpha.1'

  end

  
  
end

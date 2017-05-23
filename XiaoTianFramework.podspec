# pod lib lint XiaoTianFramework.podspec --allow-warnings
#
Pod::Spec.new do |s|
  s.name         = "XiaoTianFramework"
  s.version      = “2.0.0”
  s.summary      = "This is XiaoTianFramework. contain some useful and funny tool."
  s.description  = "This is XiaoTianFramework. contain some useful and funny tool. as  1.Util for model. 2.Util for network. 3.Util for json. 4.Util for Anyobject. 5.any more…"
  s.homepage     = "https://github.com/IOSOrganaization"
  s.license      = "MIT"
  s.authors      = { "xiaotian" => "gtrstudio@qq.com" ,'liang' => 'xiaotian@qq.com'}
  s.platform     = :ios
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/IOSOrganaization/XiaoTianFramework.git", :tag => s.version }
  s.source_files  = "XiaoTianFramework/**/*.{h,m,swift,c,mm}"
  s.exclude_files = "Classes/Exclude","XiaoTianFramework/XiaoTianFramework.h"
  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  s.frameworks = "Foundation","UIKit","SystemConfiguration"
  s.library   = "objc"
  # s.libraries = "libobjc", "xml2"
  s.requires_arc = true
  #s.framework      = 'XiaoTianFramework'
  #
  s.subspec 'no-arc' do |sp|
    sp.source_files = 'XiaoTianFramework/EmailSmtp/*.{h,m}', "XiaoTianFramework/Util/UncaughtExceptionHandler.{h,m}"
    sp.requires_arc = false
    sp.compiler_flags = '-fno-objc-arc'
  end

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"
  #s.SWIFT_VERSION = 2.3
end

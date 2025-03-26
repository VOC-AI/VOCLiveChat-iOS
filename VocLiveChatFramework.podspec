Pod::Spec.new do |s|
  # 库的名称
  s.name             = 'VocLiveChatFramework'
  # 库的版本号
  s.version          = '1.1.2'
  # 库的简短描述
  s.summary          = 'A short description of VocLiveChatFramework.'
  # 库的详细描述
  s.description      = <<-DESC
  A more detailed description of YourFrameworkName.
                       DESC
  # 库的主页 URL
  s.homepage         = 'https://github.com/VOC-AI/VOCLiveChat-iOS.git'
  # 库的许可证信息
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  # 库的作者信息
  s.author           = { 'Your Name' => 'anti2moron@gmail.com' }
  # 库的源代码所在的 Git 仓库 URL
  s.source           = { :git => 'https://github.com/VOC-AI/VOCLiveChat-iOS.git', :tag => s.version.to_s }
  # 支持的 iOS 最低版本
  s.ios.deployment_target = '12.0'
  # Framework 的源代码文件路径
  s.source_files = 'VocalWebcomponent/**/*.{h,m}'
  s.vendored_frameworks = '*/VocalWebcomponent.framework'
  s.pod_target_xcconfig = {'VALID_ARCHS' => 'arm64 x86_64 armv7'}
  # s.resource_bundles = {
  #   'YourFrameworkName' => ['YourFrameworkName/Assets/*.png']
  # }
end
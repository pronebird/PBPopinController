Pod::Spec.new do |s|
  s.name     = 'PBPopinController'
  s.version  = '0.4.1'
  s.license  = 'MIT'
  s.summary  = 'Custom container controller with keyboard-like presentation.'
  s.homepage = 'https://github.com/pronebird/PBPopinController'
  s.authors  = {
    'Andrej Mihajlov' => 'and@codeispoetry.ru'
  }
  s.source   = {
    :git => 'https://github.com/pronebird/PBPopinController.git',
    :tag => s.version.to_s
  }
  s.source_files = 'Classes/*.{h,m}'
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
end

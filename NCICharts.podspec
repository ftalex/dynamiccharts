Pod::Spec.new do |s|

  s.name         = 'NCISpeedCharts'
  s.version      = '2.1.0'
  s.summary      = 'Simple, zoom, dynamic and charts with ranges for iOS'

  s.description  = <<-DESC
  Simple, zoom, dynamic and graph with ranges for iOS.
  Highly customizable grid and axis.
  Support smooth line.
                   DESC
  s.license      = 'Apache 2.0'
  s.authors      = {'FlowForwarding' => 'dostanko@gmail.by', 'ftalex' => 'thefatalex@gmail.com'}
  s.homepage     = 'https://github.com/ftalex/optimizeddynamiccharts'
  s.platform     = :ios
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.source       = { :git => 'https://github.com/ftalex/optimizeddynamiccharts.git', :tag => s.version.to_s}

  s.source_files = 'NCIChart/**/*.{h,m}'

end

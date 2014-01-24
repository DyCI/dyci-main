Pod::Spec.new do |s|
  s.name         = "dyci"
  s.version      = "0.1.5.20140124"
  s.summary      = "Dynamic code injection tool. Allows to inject code at runtime."

  s.homepage     = "https://github.com/DyCI/dyci-main"
  s.license      = 'MIT'

  s.author       = { "Paul Taykalo" => "tt.kilew@gmail.com" }

  s.source       = { :git => "https://github.com/DyCI/dyci-main.git" }

  s.platform     = :ios, '5.0'

  #...

  s.subspec 'Core' do |sp|
    sp.source_files = 'Dynamic Code Injection/dyci/Classes/*.{h,m}'
    sp.compiler_flags = '-fobjc-arc'
  end

  s.subspec 'Injections' do |sp|
    sp.source_files = 'Dynamic Code Injection/dyci/Classes/Injections/NSObject*.{h,m}'
    sp.compiler_flags = '-fno-objc-arc'
  end

  s.subspec 'UIKit Support' do |sp|
    sp.source_files = 'Dynamic Code Injection/dyci/Classes/Injections/*Support.{h,m}'
    sp.compiler_flags = '-fobjc-arc'
  end

  s.subspec 'Helpers' do |sp|
    sp.source_files = 'Dynamic Code Injection/dyci/Classes/{FileWatcher,Categories,Notifications}/*.{h,m}'
    sp.compiler_flags = '-fobjc-arc'
  end
 
end

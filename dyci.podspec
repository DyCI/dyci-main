Pod::Spec.new do |s|
  s.name         = "dyci"
  s.version      = "0.0.4.10232012"
  s.summary      = "Dynamic code injection tool. Allows to inject code at runtime."

  s.homepage     = "https://github.com/DyCI/dyci-main"
  s.license      = 'MIT'

  s.author       = { "Paul Taykalo" => "tt.kilew@gmail.com" }

  s.source       = { :git => "https://github.com/DyCI/dyci-main.git", :tag => 'v0.1.2' }

  s.platform     = :ios, '4.3'

  s.source_files = 'Dynamic Code Injection/dyci/Classes/*.{h,m}'
  s.requires_arc = true

  #...

  s.subspec 'Injections' do |sp|
    sp.source_files = 'Dynamic Code Injection/dyci/Classes/Injections/*.{h,m}'
    sp.compiler_flags = '-fobjc-no-arc'
    sp.requires_arc = false
  end

  s.subspec 'Helpers' do |sp|
    sp.source_files = 'Dynamic Code Injection/dyci/Classes/{FileWatcher,Categories}/*.{h,m}'
  end


end
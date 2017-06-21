Pod::Spec.new do |s|

  s.name         = "XZPickView"
  s.version      = "1"
  s.summary      = "XZPickView."

  s.description  = <<-DESC
                    this is XZPickView
                   DESC

  s.homepage     = "https://github.com/zyj179638121/XZPickView"

  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author       = "zhaoyongjie"

  s.platform     = :ios, "8.0"

  s.source       = { :git => "git@github.com:zyj179638121/XZPickView.git", :tag => s.version.to_s }

  s.source_files  = "XZPickView/XZPickView/*.{h,m}"

  s.requires_arc = true

  s.dependency "Masonry"
 
end

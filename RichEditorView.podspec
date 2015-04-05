Pod::Spec.new do |s|
  s.name             = "RichEditorView"
  s.version          = "0.1.0"
  s.summary          = "A beautiful Rich Text Editor for iOS in Swift"
  s.homepage         = "https://github.com/cjwirth/RichEditorView"
  s.license          = 'BSD 3-clause'
  s.author           = { "Caesar Wirth" => "cjwirth@gmail.com" }
  s.source           = { :git => "https://github.com/cjwirth/RichEditorView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/cjwirth'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'RichEditorView/Classes/*'
  s.resources = [
      'RichEditorView/Assets/icons/*',
      'RichEditorView/Assets/editor/*'
    ]
end

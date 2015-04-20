//
//  RichEditor.swift
//
//  Created by Caesar Wirth on 4/1/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit

/**
    RichEditorDelegate defines callbacks for the delegate of the RichEditorView
*/
public protocol RichEditorDelegate: class {

    /**
        Called when the inner height of the text being displayed changes
        Can be used to update the UI
    */
    func richEditor(editor: RichEditorView, heightDidChange height: Int)

    /**
        Called whenever the content inside the view changes
    */
    func richEditor(editor: RichEditorView, contentDidChange content: String)

    /**
        Called when the rich editor starts editing
    */
    func richEditorTookFocus(editor: RichEditorView)
    
    /**
        Called when the rich editor stops editing or loses focus
    */
    func richEditorLostFocus(editor: RichEditorView)
    
    /**
        Called when the RichEditorView has become ready to receive input
        More concretely, is called when the internal UIWebView loads for the first time, and contentHTML is set
    */
    func richEditorDidLoad(editor: RichEditorView)
}

/**
    RichEditorView is a UIView that displays richly styled text, and allows it to be edited in a WYSIWYG fashion.
*/
public class RichEditorView: UIView {

    /**
        The delegate that will receive callbacks when certain actions are completed.
    */
    public weak var delegate: RichEditorDelegate?

    /**
        The internal UIWebView that is used to display the text.
    */
    public var webView: UIWebView

    /**
        Whether or not scroll is enabled on the view.
    */
    public var scrollEnabled: Bool = true {
        didSet {
            webView.scrollView.scrollEnabled = scrollEnabled
        }
    }
    
    private var editingEnabledVar = true
    public var editingEnabled: Bool {
        get { return isContentEditable() }
        set { setContentEditable(newValue) }
    }

    private var editorLoaded = false
    
    /**
        The internal height of the text being displayed.
        Is continually being updated as the text is edited.
    */
    private(set) var editorHeight: Int = 0 {
        didSet {
            delegate?.richEditor(self, heightDidChange: editorHeight)
        }
    }

    /**
        The content HTML of the text being displayed.
        Is continually updated as the text is being edited.
    */
    private(set) var contentHTML: String = "" {
        didSet {
            delegate?.richEditor(self, contentDidChange: contentHTML)
        }
    }

    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        webView = UIWebView()
        super.init(frame: frame)
        setup()
    }

    required public init(coder aDecoder: NSCoder) {
        webView = UIWebView()
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.redColor()
        
        webView.frame = self.bounds
        webView.delegate = self
        webView.keyboardDisplayRequiresUserAction = false
        webView.scalesPageToFit = false
        webView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        webView.dataDetectorTypes = .None
        webView.backgroundColor = UIColor.whiteColor()
        
        webView.scrollView.scrollEnabled = scrollEnabled
        webView.scrollView.bounces = false
        webView.scrollView.delegate = self
        
        webView.cjw_hidesInputAccessoryView = true
        
        self.addSubview(webView)
        
        if let filePath = NSBundle(forClass: RichEditorView.self).pathForResource("rich_editor", ofType: "html") {
            if let url = NSURL(fileURLWithPath: filePath) {
                let request = NSURLRequest(URL: url)
                webView.loadRequest(request)
            }
        }
    }
}


// MARK: - Rich Text Editing
extension RichEditorView {

    private func updateHeight() {
        let heightStr = runJS("document.getElementById('editor').clientHeight;")
        let height = (heightStr as NSString).integerValue
        if editorHeight != height {
            editorHeight = height
        }
    }

    private func isContentEditable() -> Bool {
        if editorLoaded {
            let value = runJS("RE.editor.isContentEditable") as NSString
            editingEnabledVar = value.boolValue
            return editingEnabledVar
        }
        return editingEnabledVar
    }
    
    private func setContentEditable(editable: Bool) {
        editingEnabledVar = editable
        if editorLoaded {
            let value = editable ? "true" : "false"
            runJS("RE.editor.contentEditable = \(value);")
        }
    }
    
    public func setHTML(html: String) {
        contentHTML = html
        if editorLoaded {
            runJS("RE.setHtml('\(escape(html))');")
            updateHeight()
        }
    }
    
    public func getHTML() -> String {
        return runJS("RE.getHtml();")
    }
    
    public func getText() -> String {
        return runJS("RE.getText()")
    }

    public func removeFormat() {
        runJS("RE.removeFormat();")
    }
    
    public func setFontSize(size: Int) {
        runJS("RE.setFontSize('\(size))px');")
    }
    
    public func setEditorBackgroundColor(color: UIColor) {
        let hex = colorToHex(color)
        runJS("RE.setBackgroundColor('\(hex)');")
    }
    
    public func undo() {
        runJS("RE.undo();")
    }
    
    public func redo() {
        runJS("RE.redo();")
    }
    
    public func bold() {
        runJS("RE.setBold();")
    }
    
    public func italic() {
        runJS("RE.setItalic();")
    }
    
    // "superscript" is a keyword
    public func subscriptText() {
        runJS("RE.setSubscript();")
    }
    
    public func superscript() {
        runJS("RE.setSuperscript();")
    }
    
    public func strikethrough() {
        runJS("RE.setStrikeThrough();")
    }
    
    public func underline() {
        runJS("RE.setUnderline();")
    }
    
    public func setTextColor(color: UIColor) {
        runJS("RE.prepareInsert();")
        
        let hex = colorToHex(color)
        runJS("RE.setTextColor('\(hex)');")
    }
    
    public func setTextBackgroundColor(color: UIColor) {
        runJS("RE.prepareInsert();")
        
        let hex = colorToHex(color)
        runJS("RE.setTextBackgroundColor('\(hex)');")
    }
    
    public func header(h: Int) {
        runJS("RE.setHeading('\(h)');")
    }

    public func indent() {
        runJS("RE.setIndent();")
    }

    public func outdent() {
        runJS("RE.setOutdent();")
    }
    
    public func alignLeft() {
        runJS("RE.setJustifyLeft();")
    }
    
    public func alignCenter() {
        runJS("RE.setJustifyCenter();")
    }
    
    public func alignRight() {
        runJS("RE.setJustifyRight();")
    }
    
    public func insertImage(url: String, alt: String) {
        runJS("RE.prepareInsert();")
        runJS("RE.insertImage('\(escape(url))', '\(escape(alt))');")
    }
    
    public func insertLink(href: String, title: String) {
        runJS("RE.prepareInsert();")
        runJS("RE.insertLink('\(escape(href))', '\(escape(title))');")
    }
    
    public func focus() {
        runJS("RE.focus();")
    }
    
    public func blur() {
        runJS("RE.blurFocus()")
    }
    
}


// MARK: - UIScrollViewDelegate
extension RichEditorView: UIScrollViewDelegate {

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        // We use this to keep the scroll view from changing its offset when the keyboard comes up
        if !scrollEnabled {
            scrollView.bounds = webView.bounds
        }
    }
}


// MARK: - UIWebViewDelegate
extension RichEditorView: UIWebViewDelegate {

    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let callbackPrefix = "re-callback://"
        let prefixRange = callbackPrefix.startIndex..<callbackPrefix.endIndex
        
        if request.URL?.absoluteString?.hasPrefix(callbackPrefix) == true {
            if let method = request.URL?.absoluteString?.stringByReplacingCharactersInRange(prefixRange, withString: "") {
                
                if method.hasPrefix("ready") {
                    // If loading for the first time, we have to set the content HTML to be displayed
                    if !editorLoaded {
                        editorLoaded = true
                        setHTML(contentHTML)
                        setContentEditable(editingEnabledVar)
                        delegate?.richEditorDidLoad(self)
                    }
                    updateHeight()
                }
                else if method.hasPrefix("input") {
                    let content = runJS("RE.getHtml()")
                    contentHTML = content
                    updateHeight()
                }
                else if method.hasPrefix("focus") {
                    delegate?.richEditorTookFocus(self)
                }
                else if method.hasPrefix("blur") {
                    delegate?.richEditorLostFocus(self)
                }
            }

            return false
        }
        
        return true
    }
    
}


// MARK: - Utilities
extension RichEditorView {

    /**
        Converts a UIColor to its representation in hexadecimal
        For example, UIColor.blackColor() becomes "#000000"
        
        :param:   color The color to convert to hex
        :returns: The hexadecimal representation of the color
    */
    private func colorToHex(color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)

        let r = Int(255.0 * red)
        let g = Int(255.0 * green)
        let b = Int(255.0 * blue)

        let str = NSString(format: "#%02x%02x%02x", r, g, b)
        return str as String
    }

    /**
        Escapes the ' character in a String
        Used when passing a string into JavaScript, so the string is not completed too soon
    
        :param:   string The string to be escaped
        :returns: The string with all ' characters escaped
    */
    private func escape(string: String) -> String {
        let unicode = string.unicodeScalars
        var newString = ""
        for var i = unicode.startIndex; i < unicode.endIndex; i++ {
            let char = unicode[i]
            if char.value == 39 { // 39 == ' in ASCII
                let escaped = char.escape(asASCII: true)
                newString.extend(escaped)
            } else {
                newString.append(char)
            }
        }
        return newString
    }

    /**
        Runs some JavaScript on the UIWebView and returns the result
        If there is no result, returns an empty string
    
        :param:   js The JavaScript string to be run
        :returns: The result of the JavaScript that was run
    */
    private func runJS(js: String) -> String {
        let string = webView.stringByEvaluatingJavaScriptFromString(js) ?? ""
        return string
    }
}

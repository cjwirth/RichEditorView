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
@objc public protocol RichEditorDelegate: NSObjectProtocol {

    /**
        Called when the inner height of the text being displayed changes
        Can be used to update the UI
    */
    @objc optional func richEditor(_ editor: RichEditorView, heightDidChange height: Int)

    /**
        Called whenever the content inside the view changes
    */
    @objc optional func richEditor(_ editor: RichEditorView, contentDidChange content: String)

    /**
        Called when the rich editor starts editing
    */
    @objc optional func richEditorTookFocus(_ editor: RichEditorView)
    
    /**
        Called when the rich editor stops editing or loses focus
    */
    @objc optional func richEditorLostFocus(_ editor: RichEditorView)
    
    /**
        Called when the RichEditorView has become ready to receive input
        More concretely, is called when the internal UIWebView loads for the first time, and contentHTML is set
    */
    @objc optional func richEditorDidLoad(_ editor: RichEditorView)
    
    /**
        Called when the internal UIWebView begins loading a URL that it does not know how to respond to
        For example, if there is an external link, and then the user taps it
    */
    @objc optional func richEditor(_ editor: RichEditorView, shouldInteractWithURL url: URL) -> Bool
    
    /**
        Called when custom actions are called by callbacks in the JS
        By default, this method is not used unless called by some custom JS that you add
    */
    @objc optional func richEditor(_ editor: RichEditorView, handleCustomAction action: String)
}

/**
    RichEditorView is a UIView that displays richly styled text, and allows it to be edited in a WYSIWYG fashion.
*/
open class RichEditorView: UIView {

    /**
        The delegate that will receive callbacks when certain actions are completed.
    */
    open weak var delegate: RichEditorDelegate?

    /**
        Whether or not scroll is enabled on the view.
    */
    open var scrollEnabled: Bool = true {
        didSet {
            webView.scrollView.isScrollEnabled = scrollEnabled
        }
    }

    /**
        Input accessory view to display over they keyboard.
        Defaults to nil
    */
    open override var inputAccessoryView: UIView? {
        get { return webView.cjw_inputAccessoryView }
        set { webView.cjw_inputAccessoryView = newValue }
    }

    /**
        The internal UIWebView that is used to display the text.
    */
    open fileprivate(set) var webView: UIWebView
    
    /**
        Whether or not to allow user input in the view.
    */
    fileprivate var editingEnabledVar = true
    open var editingEnabled: Bool {
        get { return isContentEditable() }
        set { setContentEditable(newValue) }
    }
    
    /**
        The placeholder text that should be shown when there is no user input.
        To set, use `setPlaceholderText(text: String)`
    */
    open fileprivate(set) var placeholder: String = ""

    fileprivate var editorLoaded = false
    
    /**
        The internal height of the text being displayed.
        Is continually being updated as the text is edited.
    */
    open fileprivate(set) var editorHeight: Int = 0 {
        didSet {
            delegate?.richEditor?(self, heightDidChange: editorHeight)
        }
    }

    /**
        The content HTML of the text being displayed.
        Is continually updated as the text is being edited.
    */
    open fileprivate(set) var contentHTML: String = "" {
        didSet {
            delegate?.richEditor?(self, contentDidChange: contentHTML)
        }
    }

    /**
        The inner height of the editor div.
        Fetches it from JS every time, so might be slow!
    */
    fileprivate var clientHeight: Int {
        let heightStr = runJS("document.getElementById('editor').clientHeight;")
        return (heightStr as NSString).integerValue
    }

    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        webView = UIWebView()
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        webView = UIWebView()
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        self.backgroundColor = UIColor.red
        
        webView.frame = self.bounds
        webView.delegate = self
        webView.keyboardDisplayRequiresUserAction = false
        webView.scalesPageToFit = false
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.dataDetectorTypes = UIDataDetectorTypes()
        webView.backgroundColor = UIColor.white
        
        webView.scrollView.isScrollEnabled = scrollEnabled
        webView.scrollView.bounces = false
        webView.scrollView.delegate = self
        webView.scrollView.clipsToBounds = false
        
        webView.cjw_inputAccessoryView = nil
        
        self.addSubview(webView)
        
        if let filePath = Bundle(for: RichEditorView.self).path(forResource: "rich_editor", ofType: "html") {
            let url = URL(fileURLWithPath: filePath, isDirectory: false)
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RichEditorView.viewWasTapped))
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)
    }
}


// MARK: - Rich Text Editing
extension RichEditorView {


    public func setHTML(_ html: String) {
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
    
    public func setPlaceholderText(_ text: String) {
        placeholder = text
        runJS("RE.setPlaceholderText('\(escape(text))');")
    }
    
    public func removeFormat() {
        runJS("RE.removeFormat();")
    }
    
    public func setFontSize(_ size: Int) {
        runJS("RE.setFontSize('\(size)px');")
    }
    
    public func setEditorBackgroundColor(_ color: UIColor) {
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
    
    public func setTextColor(_ color: UIColor) {
        runJS("RE.prepareInsert();")
        
        let hex = colorToHex(color)
        runJS("RE.setTextColor('\(hex)');")
    }
    
    public func setTextBackgroundColor(_ color: UIColor) {
        runJS("RE.prepareInsert();")
        
        let hex = colorToHex(color)
        runJS("RE.setTextBackgroundColor('\(hex)');")
    }
    
    public func header(_ h: Int) {
        runJS("RE.setHeading('\(h)');")
    }

    public func indent() {
        runJS("RE.setIndent();")
    }

    public func outdent() {
        runJS("RE.setOutdent();")
    }

    public func orderedList() {
        runJS("RE.setOrderedList();")
    }

    public func unorderedList() {
        runJS("RE.setUnorderedList();")
    }

    public func blockquote() {
        runJS("RE.setBlockquote()");
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
    
    public func insertImage(_ url: String, alt: String) {
        runJS("RE.prepareInsert();")
        runJS("RE.insertImage('\(escape(url))', '\(escape(alt))');")
    }
    
    public func insertLink(_ href: String, title: String) {
        runJS("RE.prepareInsert();")
        runJS("RE.insertLink('\(escape(href))', '\(escape(title))');")
    }
    
    public func focus() {
        runJS("RE.focus();")
    }
    
    public func blur() {
        runJS("RE.blurFocus()")
    }

    /**
        Looks specifically for a selection of type "Range"
    */
    public func rangeSelectionExists() -> Bool {
        return runJS("RE.rangeSelectionExists();") == "true" ? true : false
    }

    /**
        Looks specifically for a selection of type "Range" or "Caret"
    */
    public func rangeOrCaretSelectionExists() -> Bool {
        return runJS("RE.rangeOrCaretSelectionExists();") == "true" ? true : false
    }

    /**
        If the current selection's parent is an anchor tag, get the href.
        - returns: nil if href is empty, otherwise a non-empty String
    */
    public func getSelectedHref() -> String? {
        if !rangeSelectionExists() { return nil }
        let href = runJS("RE.getSelectedHref();")
        if href == "" {
            return nil
        } else {
            return href
        }
    }

    /**
        Runs some JavaScript on the UIWebView and returns the result
        If there is no result, returns an empty string
        
        - parameter js: The JavaScript string to be run
        - returns: The result of the JavaScript that was run
    */
    public func runJS(_ js: String) -> String {
        let string = webView.stringByEvaluatingJavaScript(from: js) ?? ""
        return string
    }
}


// MARK: - UIScrollViewDelegate
extension RichEditorView: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // We use this to keep the scroll view from changing its offset when the keyboard comes up
        if !scrollEnabled {
            scrollView.bounds = webView.bounds
        }
    }
}


// MARK: - UIWebViewDelegate
extension RichEditorView: UIWebViewDelegate {

    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {

        // Handle pre-defined editor actions
        let callbackPrefix = "re-callback://"
        if request.url?.absoluteString.hasPrefix(callbackPrefix) == true {
            
            // When we get a callback, we need to fetch the command queue to run the commands
            // It comes in as a JSON array of commands that we need to parse
            let commands = runJS("RE.getCommandQueue();")
            if let data = (commands as NSString).data(using: String.Encoding.utf8.rawValue) {
                
                let jsonCommands: [String]?
                do {
                    jsonCommands = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String]
                } catch {
                    jsonCommands = nil
                    NSLog("Failed to parse JSON Commands")
                }
                
                if let jsonCommands = jsonCommands {
                    for command in jsonCommands {
                        performCommand(command)
                    }
                }
            }

            return false
        }
        
        // User is tapping on a link, so we should react accordingly
        if navigationType == .linkClicked {
            if let
                url = request.url,
                let shouldInteract = delegate?.richEditor?(self, shouldInteractWithURL:url)
            {
                return shouldInteract
            }
        }
        
        return true
    }
    
}


// MARK: UIGestureRecognizerDelegate
extension RichEditorView: UIGestureRecognizerDelegate {

    /**
        Delegate method for our UITapGestureDelegate.
        Since the internal web view also has gesture recognizers, we have to make sure that we actually receive our taps.
    */
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}


// MARK: - Private Implementation Details
extension RichEditorView {

    fileprivate func updateHeight() {
        let heightStr = runJS("document.getElementById('editor').clientHeight;")
        let height = (heightStr as NSString).integerValue
        if editorHeight != height {
            editorHeight = height
        }
    }

    fileprivate func isContentEditable() -> Bool {
        if editorLoaded {
            let value = runJS("RE.editor.isContentEditable") as NSString
            editingEnabledVar = value.boolValue
            return editingEnabledVar
        }
        return editingEnabledVar
    }
    
    fileprivate func setContentEditable(_ editable: Bool) {
        editingEnabledVar = editable
        if editorLoaded {
            let value = editable ? "true" : "false"
            runJS("RE.editor.contentEditable = \(value);")
        }
    }
    
    /**
        Returns the position of the caret relative to the currently shown content.

        For example, if the cursor is directly at the top of what is visible, it will return 0.
        This also means that it will be negative if it is above what is currently visible.
        Can also return 0 if some sort of error occurs between JS and here.

        - returns: Relative offset position of the caret
     */
    fileprivate func getRelativeCaretYPosition() -> Int {
        let string = runJS("RE.getRelativeCaretYPosition();")
        return (string as NSString).integerValue
    }

    /**
        Scrolls the editor to a position where the caret is visible.
        Called repeatedly to make sure the caret is always visible when inputting text.
    */
    fileprivate func scrollCaretToVisible() {
        let scrollView = self.webView.scrollView
        
        let contentHeight = clientHeight > 0 ? CGFloat(clientHeight) : scrollView.frame.height
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
        
        // TODO: Make these either more dynamic or customizable!
        let lineHeight: CGFloat = 28.0
        let cursorHeight: CGFloat = 24.0
        let caretPosition = getRelativeCaretYPosition()
        let visiblePosition = CGFloat(caretPosition)
        var offset: CGPoint?

        if visiblePosition + cursorHeight > scrollView.bounds.size.height {
            // Visible caret position goes further than our bounds
            offset = CGPoint(x: 0, y: (visiblePosition + lineHeight) - scrollView.bounds.height + scrollView.contentOffset.y)

        } else if visiblePosition < 0 {
            // Visible caret position is above what is currently visible
            var amount = scrollView.contentOffset.y + visiblePosition
            amount = amount < 0 ? 0 : amount
            offset = CGPoint(x: scrollView.contentOffset.x, y: amount)

        }

        if let offset = offset {
            scrollView.setContentOffset(offset, animated: true)
        }
    }
    
    /**
        Converts a UIColor to its representation in hexadecimal
        For example, UIColor.blackColor() becomes "#000000"
        
        - parameter   color: The color to convert to hex
        - returns: The hexadecimal representation of the color
    */
    fileprivate func colorToHex(_ color: UIColor) -> String {
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
    
        - parameter   string: The string to be escaped
        - returns: The string with all ' characters escaped
    */
    fileprivate func escape(_ string: String) -> String {
        let unicode = string.unicodeScalars
        var newString = ""

        for i in unicode.indices {
            let char = unicode[i]
            if char.value < 9 || (char.value > 9 && char.value < 32) // < 32 == special characters in ASCII, 9 == horizontal tab in ASCII
                || char.value == 39 { // 39 == ' in ASCII
                let escaped = char.escaped(asASCII: true)
                newString.append(escaped)
            } else {
                newString.append(String(char))
            }
        }
        return newString
    }
    
    /**
        Called when actions are received from JavaScript
        
        - parameter method: String with the name of the method and optional parameters that were passed in
    */
    fileprivate func performCommand(_ method: String) {
        if method.hasPrefix("ready") {
            // If loading for the first time, we have to set the content HTML to be displayed
            if !editorLoaded {
                editorLoaded = true
                setHTML(contentHTML)
                setContentEditable(editingEnabledVar)
                setPlaceholderText(placeholder)
                delegate?.richEditorDidLoad?(self)
            }
            updateHeight()
        }
        else if method.hasPrefix("input") {
            scrollCaretToVisible()
            let content = runJS("RE.getHtml()")
            contentHTML = content
            updateHeight()
        }
        else if method.hasPrefix("updateHeight") {
            updateHeight()
        }
        else if method.hasPrefix("focus") {
            delegate?.richEditorTookFocus?(self)
        }
        else if method.hasPrefix("blur") {
            delegate?.richEditorLostFocus?(self)
        }
        else if method.hasPrefix("action/") {
            let content = runJS("RE.getHtml()")
            contentHTML = content
            
            // If there are any custom actions being called
            // We need to tell the delegate about it
            let actionPrefix = "action/"
            let range = (actionPrefix.characters.indices)
            let action = method.replacingCharacters(in: range.startIndex..<range.endIndex, with: "")

            delegate?.richEditor?(self, handleCustomAction: action)
        }
    }

    /**
        Called by the UITapGestureRecognizer when the user taps the view.
        If we are not already the first responder, focus the editor.
    */
    internal func viewWasTapped() {
        if !webView.containsFirstResponder {
            focus()
        }
    }
    
}

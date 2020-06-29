    //
//  RichEditor.swift
//
//  Created by Caesar Wirth on 4/1/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit
import WebKit

/// The value we hold in order to be able to set the line height before the JS completely loads.
private let DefaultInnerLineHeight: Int = 21
var ToolbarHandle: UInt8 = 0
/// RichEditorDelegate defines callbacks for the delegate of the RichEditorView
@objc public protocol RichEditorDelegate: class {
    /// Called when the inner height of the text being displayed changes
    /// Can be used to update the UI
    @objc optional func richEditor(_ editor: RichEditorView, heightDidChange height: Int)

    /// Called whenever the content inside the view changes
    @objc optional func richEditor(_ editor: RichEditorView, contentDidChange content: String)

    /// Called when the rich editor starts editing
    @objc optional func richEditorTookFocusAt(_ editor: RichEditorView, at: CGPoint)

    /// Called when the rich editor starts editing
    @objc optional func richEditorTookFocus(_ editor: RichEditorView)

    /// Called when the rich editor stops editing or loses focus
    @objc optional func richEditorLostFocus(_ editor: RichEditorView)

    /// Called when the RichEditorView has become ready to receive input
    /// More concretely, is called when the internal WKWebView loads for the first time, and contentHTML is set
    @objc optional func richEditorDidLoad(_ editor: RichEditorView)

    /// Called when the internal WKWebView begins loading a URL that it does not know how to respond to
    /// For example, if there is an external link, and then the user taps it
    @objc optional func richEditor(_ editor: RichEditorView, shouldInteractWith url: URL) -> Bool

    /// Called when custom actions are called by callbacks in the JS
    /// By default, this method is not used unless called by some custom JS that you add
    @objc optional func richEditor(_ editor: RichEditorView, handle action: String)
}

/// RichEditorView is a UIView that displays richly styled text, and allows it to be edited in a WYSIWYG fashion.
@objcMembers open class RichEditorView: UIView, UIScrollViewDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {
    /// The delegate that will receive callbacks when certain actions are completed.
    open weak var delegate: RichEditorDelegate?

    /// Input accessory view to display over they keyboard.
    /// Defaults to nil

    open override var inputAccessoryView: UIView? { get { if #available(iOS 13.0, *) { return webView.accessoryView } else { return webView.getCustomInputAccessoryView() } } set { if #available(iOS 13.0, *) { webView.accessoryView = newValue } else { webView.addInputAccessoryView(toolbar: newValue) } } }
    /// The internal WKWebView that is used to display the text.
    open private(set) var webView: RichEditorWebView

    /// Whether or not scroll is enabled on the view.
    open var isScrollEnabled: Bool = true {
        didSet {
            webView.scrollView.isScrollEnabled = isScrollEnabled
        }
    }

    /// Whether or not to allow user input in the view.
    open var editingEnabled: Bool = false {
        didSet { contentEditable = editingEnabled }
    }

    /// The content HTML of the text being displayed.
    /// Is continually updated as the text is being edited.
    open private(set) var contentHTML: String = "" {
        didSet {
            delegate?.richEditor?(self, contentDidChange: contentHTML)
        }
    }

    /// The internal height of the text being displayed.
    /// Is continually being updated as the text is edited.
    open private(set) var editorHeight: Int = 0 {
        didSet {
            delegate?.richEditor?(self, heightDidChange: editorHeight)
        }
    }

    /// The line height of the editor. Defaults to 21.
    open private(set) var lineHeight: Int = DefaultInnerLineHeight {
        didSet {
            runJS("RE.setLineHeight('\(lineHeight)px')")
        }
    }

    /// Whether or not the editor has finished loading or not yet.
    private var isEditorLoaded = false

    /// Value that stores whether or not the content should be editable when the editor is loaded.
    /// Is basically `isEditingEnabled` before the editor is loaded.
    private var editingEnabledVar = true

    /// The HTML that is currently loaded in the editor view, if it is loaded. If it has not been loaded yet, it is the
    /// HTML that will be loaded into the editor view once it finishes initializing.
    public var html: String = "" {
        didSet {
            setHTML(html)
        }
    }

    /// Private variable that holds the placeholder text, so you can set the placeholder before the editor loads.
    private var placeholderText: String = ""
    /// The placeholder text that should be shown when there is no user input.
    open var placeholder: String {
        get { return placeholderText }
        set {
            placeholderText = newValue
            if isEditorLoaded {
                runJS("RE.setPlaceholderText('\(newValue.escaped)')")
            }
        }
    }

    // MARK: Initialization

    public override init(frame: CGRect) {
        webView = RichEditorWebView()
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        webView = RichEditorWebView()
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        // configure webview
        webView.frame = bounds
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if #available(iOS 10.0, *) {
            webView.configuration.dataDetectorTypes = WKDataDetectorTypes()
        } else {
            // Fallback on earlier versions
        }
        webView.scrollView.isScrollEnabled = isScrollEnabled
        webView.scrollView.bounces = true
        webView.scrollView.delegate = self
        webView.scrollView.clipsToBounds = false
        addSubview(webView)

        if let filePath = Bundle(for: RichEditorView.self).path(forResource: "rich_editor", ofType: "html") {
            let url = URL(fileURLWithPath: filePath, isDirectory: false)
            if #available(iOS 9.0, *) {
                webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            } else {
                // Fallback on earlier versions
            }
        }
    }

    // MARK: - Rich Text Editing

    open func isEditingEnabled(handler: @escaping (Bool) -> Void) {
        isContentEditable(handler: handler)
    }

    private func getLineHeight(handler: @escaping (Int) -> Void) {
        if isEditorLoaded {
            runJS("RE.getLineHeight()") { r in
                if let r = Int(r) {
                    handler(r)
                } else {
                    handler(DefaultInnerLineHeight)
                }
            }
        } else {
            handler(DefaultInnerLineHeight)
        }
    }

    private func setHTML(_ value: String) {
        if isEditorLoaded {
            runJS("RE.setHtml('\(value.escaped)')") { _ in
                self.updateHeight()
            }
        }
    }

    /// The inner height of the editor div.
    /// Fetches it from JS every time, so might be slow!
    private func getClientHeight(handler: @escaping (Int) -> Void) {
        runJS("document.getElementById('editor').clientHeight") { r in
            if let r = Int(r) {
                handler(r)
            } else {
                handler(0)
            }
        }
    }

    public func getHtml(handler: @escaping (String) -> Void) {
        runJS("RE.getHtml()") { r in
            handler(r)
        }
    }

    /// Text representation of the data that has been input into the editor view, if it has been loaded.
    public func getText(handler: @escaping (String) -> Void) {
        runJS("RE.getText()") { r in
            handler(r)
        }
    }

    /// The href of the current selection, if the current selection's parent is an anchor tag.
    /// Will be nil if there is no href, or it is an empty string.
    public func getSelectedHref(handler: @escaping (String?) -> Void) {
        hasRangeSelection(handler: { r in
            if !r {
                handler(nil)
                return
            }
            self.runJS("RE.getSelectedHref()") { r in
                if r == "" {
                    handler(nil)
                } else {
                    handler(r)
                }
            }
        })
    }

    /// Whether or not the selection has a type specifically of "Range".
    public func hasRangeSelection(handler: @escaping (Bool) -> Void) {
        runJS("RE.rangeSelectionExists()") { r in
            handler(r == "true" ? true : false)
        }
    }

    /// Whether or not the selection has a type specifically of "Range" or "Caret".
    public func hasRangeOrCaretSelection(handler: @escaping (Bool) -> Void) {
        runJS("RE.rangeOrCaretSelectionExists()") { r in
            handler(r == "true" ? true : false)
        }
    }

    // MARK: Methods

    public func removeFormat() {
        runJS("RE.removeFormat()")
    }

    public func setFontSize(_ size: Int) {
        runJS("RE.setFontSize('\(size)px')")
    }

    public func setEditorBackgroundColor(_ color: UIColor) {
        runJS("RE.setBackgroundColor('\(color.hex)')")
    }

    public func undo() {
        runJS("RE.undo()")
    }

    public func redo() {
        runJS("RE.redo()")
    }

    public func bold() {
        runJS("RE.setBold()")
    }

    public func italic() {
        runJS("RE.setItalic()")
    }

    // "superscript" is a keyword
    public func subscriptText() {
        runJS("RE.setSubscript()")
    }

    public func superscript() {
        runJS("RE.setSuperscript()")
    }

    public func strikethrough() {
        runJS("RE.setStrikeThrough()")
    }

    public func underline() {
        runJS("RE.setUnderline()")
    }

    public func setTextColor(_ color: UIColor) {
        runJS("RE.prepareInsert()")
        runJS("RE.setTextColor('\(color.hex)')")
    }

    public func setEditorFontColor(_ color: UIColor) {
        runJS("RE.setBaseTextColor('\(color.hex)')")
    }

    public func setTextBackgroundColor(_ color: UIColor) {
        runJS("RE.prepareInsert()")
        runJS("RE.setTextBackgroundColor('\(color.hex)')")
    }

    public func header(_ h: Int) {
        runJS("RE.setHeading('\(h)')")
    }

    public func indent() {
        runJS("RE.setIndent()")
    }

    public func outdent() {
        runJS("RE.setOutdent()")
    }

    public func orderedList() {
        runJS("RE.setOrderedList()")
    }

    public func unorderedList() {
        runJS("RE.setUnorderedList()")
    }

    public func blockquote() {
        runJS("RE.setBlockquote()");
    }

    public func alignLeft() {
        runJS("RE.setJustifyLeft()")
    }

    public func alignCenter() {
        runJS("RE.setJustifyCenter()")
    }

    public func alignRight() {
        runJS("RE.setJustifyRight()")
    }

    public func insertImage(_ url: String, alt: String) {
        runJS("RE.prepareInsert()")
        runJS("RE.insertImage('\(url.escaped)', '\(alt.escaped)')")
    }

    public func insertLink(_ href: String, title: String) {
        runJS("RE.prepareInsert()")
        runJS("RE.insertLink('\(href.escaped)', '\(title.escaped)')")
    }

    public func focus() {
        runJS("RE.focus()")
    }

    public func focus(at: CGPoint) {
        delegate?.richEditorTookFocusAt?(self, at: at)
        runJS("RE.focusAtPoint(\(at.x), \(at.y))")
    }

    public func blur() {
        runJS("RE.blurFocus()")
    }

    /// Runs some JavaScript on the WKWebView and returns the result
    /// If there is no result, returns an empty string
    /// - parameter js: The JavaScript string to be run
    /// - returns: The result of the JavaScript that was run
    public func runJS(_ js: String, handler: ((String) -> Void)? = nil) {
        webView.evaluateJavaScript(js) { (result, error) in
            if let error = error {
                print("WKWebViewJavascriptBridge Error: \(String(describing: error)) - JS: \(js)")
                handler?("")
                return
            }

            guard let handler = handler else {
                return
            }

            if let resultInt = result as? Int {
                handler("\(resultInt)")
                return
            }

            if let resultBool = result as? Bool {
                handler(resultBool ? "true" : "false")
                return
            }

            if let resultStr = result as? String {
                handler(resultStr)
                return
            }

            // no result
            handler("")
        }
    }

    // MARK: - Delegate Methods

    // MARK: UIScrollViewDelegate

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // We use this to keep the scroll view from changing its offset when the keyboard comes up
        if !isScrollEnabled {
            scrollView.bounds = webView.bounds
        }
    }

    // MARK: WKWebViewDelegate

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // empy
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Handle pre-defined editor actions
        let callbackPrefix = "re-callback://"
        if navigationAction.request.url?.absoluteString.hasPrefix(callbackPrefix) == true {
            // When we get a callback, we need to fetch the command queue to run the commands
            // It comes in as a JSON array of commands that we need to parse
            runJS("RE.getCommandQueue()") { commands in
                if let data = commands.data(using: .utf8) {

                    let jsonCommands: [String]
                    do {
                        jsonCommands = try JSONSerialization.jsonObject(with: data) as? [String] ?? []
                    } catch {
                        jsonCommands = []
                        NSLog("RichEditorView: Failed to parse JSON Commands")
                    }

                    jsonCommands.forEach(self.performCommand)
                }
            }
            return decisionHandler(WKNavigationActionPolicy.cancel);
        }

        // User is tapping on a link, so we should react accordingly
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                if delegate?.richEditor?(self, shouldInteractWith: url) ?? false {
                    return decisionHandler(WKNavigationActionPolicy.allow);
                }
            }
        }

        return decisionHandler(WKNavigationActionPolicy.allow);
    }

    // MARK: UIGestureRecognizerDelegate

    /// Delegate method for our UITapGestureDelegate.
    /// Since the internal web view also has gesture recognizers, we have to make sure that we actually receive our taps.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - Private Implementation Details

    private var contentEditable: Bool = false {
        didSet {
            editingEnabledVar = contentEditable
            if isEditorLoaded {
                let value = (contentEditable ? "true" : "false")
                runJS("RE.editor.contentEditable = \(value)")
            }
        }
    }
    private func isContentEditable(handler: @escaping (Bool) -> Void) {
        if isEditorLoaded {
            // to get the "editable" value is a different property, than to disable it
            // https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/contentEditable
            runJS("RE.editor.isContentEditable") { value in
                self.editingEnabledVar = Bool(value) ?? false
            }
        }
    }

    /// The position of the caret relative to the currently shown content.
    /// For example, if the cursor is directly at the top of what is visible, it will return 0.
    /// This also means that it will be negative if it is above what is currently visible.
    /// Can also return 0 if some sort of error occurs between JS and here.
    private func relativeCaretYPosition(handler: @escaping (Int) -> Void) {
        runJS("RE.getRelativeCaretYPosition()") { r in
            handler(Int(r) ?? 0)
        }
    }

    private func updateHeight() {
        runJS("document.getElementById('editor').clientHeight") { heightString in
            let height = Int(heightString) ?? 0
            if self.editorHeight != height {
                self.editorHeight = height
            }
        }
    }

    /// Scrolls the editor to a position where the caret is visible.
    /// Called repeatedly to make sure the caret is always visible when inputting text.
    /// Works only if the `lineHeight` of the editor is available.
    private func scrollCaretToVisible() {
        let scrollView = self.webView.scrollView

        getClientHeight(handler: { clientHeight in
            let contentHeight = clientHeight > 0 ? CGFloat(clientHeight) : scrollView.frame.height
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)

            // XXX: Maybe find a better way to get the cursor height
            self.getLineHeight(handler: { lh in
                let lineHeight = CGFloat(lh)
                let cursorHeight = lineHeight - 4
                self.relativeCaretYPosition(handler: { r in
                    let visiblePosition = CGFloat(r)
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
                })
            })
        })
    }

    /// Called when actions are received from JavaScript
    /// - parameter method: String with the name of the method and optional parameters that were passed in
    private func performCommand(_ method: String) {
        if method.hasPrefix("ready") {
            // If loading for the first time, we have to set the content HTML to be displayed
            if !isEditorLoaded {
                isEditorLoaded = true
                setHTML(html)
                contentHTML = html
                contentEditable = editingEnabledVar
                placeholder = placeholderText
                lineHeight = DefaultInnerLineHeight

                delegate?.richEditorDidLoad?(self)
            }
            updateHeight()
        }
        else if method.hasPrefix("input") {
            scrollCaretToVisible()
            runJS("RE.getHtml()") { content in
                self.contentHTML = content
                self.updateHeight()
            }
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
            runJS("RE.getHtml()") { content in
                self.contentHTML = content

                // If there are any custom actions being called
                // We need to tell the delegate about it
                let actionPrefix = "action/"
                let range = method.range(of: actionPrefix)!
                let action = method.replacingCharacters(in: range, with: "")

                self.delegate?.richEditor?(self, handle: action)
            }
        }
    }

    // MARK: - Responder Handling

    override open func becomeFirstResponder() -> Bool {
        if !webView.isFirstResponder {
            focus()
            return true
        } else {
            return false
        }
    }

    open override func resignFirstResponder() -> Bool {
        blur()
        return true
    }

}

    extension WKWebView {
        func addInputAccessoryView(toolbar: UIView?) {
            guard let toolbar = toolbar else {return}
            objc_setAssociatedObject(self, &ToolbarHandle, toolbar, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            var candidateView: UIView? = nil
            for view in self.scrollView.subviews {
                let description : String = String(describing: type(of: view))
                if description.hasPrefix("WKContent") {
                    candidateView = view
                    break
                }
            }
            guard let targetView = candidateView else {return}
            let newClass: AnyClass? = classWithCustomAccessoryView(targetView: targetView)

            guard let targetNewClass = newClass else {return}

            object_setClass(targetView, targetNewClass)
        }

        func classWithCustomAccessoryView(targetView: UIView) -> AnyClass? {
            guard let _ = targetView.superclass else {return nil}
            let customInputAccesoryViewClassName = "_CustomInputAccessoryView"

            var newClass: AnyClass? = NSClassFromString(customInputAccesoryViewClassName)
            if newClass == nil {
                newClass = objc_allocateClassPair(object_getClass(targetView), customInputAccesoryViewClassName, 0)
            } else {
                return newClass
            }

            let newMethod = class_getInstanceMethod(WKWebView.self, #selector(WKWebView.getCustomInputAccessoryView))
            class_addMethod(newClass.self, #selector(getter: WKWebView.inputAccessoryView), method_getImplementation(newMethod!), method_getTypeEncoding(newMethod!))

            objc_registerClassPair(newClass!)

            return newClass
        }

        @objc func getCustomInputAccessoryView() -> UIView? {
            var superWebView: UIView? = self
            while (superWebView != nil) && !(superWebView is WKWebView) {
                superWebView = superWebView?.superview
            }

            guard let webView = superWebView else {return nil}

            let customInputAccessory = objc_getAssociatedObject(webView, &ToolbarHandle)
            return customInputAccessory as? UIView
        }
    }

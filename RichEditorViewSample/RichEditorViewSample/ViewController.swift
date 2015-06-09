//
//  ViewController.swift
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 4/5/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit
import RichEditorView

class ViewController: UIViewController {
    @IBOutlet var editorView: RichEditorView!
    @IBOutlet var htmlTextView: UITextView!
    var toolbar: RichEditorToolbar { return self.keyboardManager.toolbar }

    lazy var keyboardManager: KeyboardManager = { KeyboardManager(view: self.view) }()

    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardManager.toolbar.editor = self.editorView

        editorView.delegate = self

        toolbar.delegate = self

        // We will create a custom action that clears all the input text when it is pressed
        let item = RichEditorOptionItem(image: nil, title: "Clear") { toolbar in
            toolbar?.editor?.setHTML("")
        }

        var options = toolbar.options
        options.append(item)
        toolbar.options = options
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardManager.beginMonitoring()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardManager.stopMonitoring()
    }

}

extension ViewController: RichEditorDelegate {

    func richEditor(editor: RichEditorView, heightDidChange height: Int) { }

    func richEditor(editor: RichEditorView, contentDidChange content: String) {
        if content.isEmpty {
            htmlTextView.text = "HTML Preview"
        } else {
            htmlTextView.text = content
        }
    }

    func richEditorTookFocus(editor: RichEditorView) { }
    
    func richEditorLostFocus(editor: RichEditorView) { }
    
    func richEditorDidLoad(editor: RichEditorView) { }
    
    func richEditor(editor: RichEditorView, shouldInteractWithURL url: NSURL) -> Bool { return true }
    
    func richEditor(editor: RichEditorView, handleCustomAction action: String) { }

}

extension ViewController: RichEditorToolbarDelegate {

    private func randomColor() -> UIColor {
        let colors = [
            UIColor.redColor(),
            UIColor.orangeColor(),
            UIColor.yellowColor(),
            UIColor.greenColor(),
            UIColor.blueColor(),
            UIColor.purpleColor()
        ]

        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }

    func richEditorToolbarChangeTextColor(toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }

    func richEditorToolbarChangeBackgroundColor(toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }

    func richEditorToolbarInsertImage(toolbar: RichEditorToolbar) {
        toolbar.editor?.insertImage("http://gravatar.com/avatar/696cf5da599733261059de06c4d1fe22", alt: "Gravatar")
    }

    func richEditorToolbarChangeInsertLink(toolbar: RichEditorToolbar) {
        toolbar.editor?.insertLink("http://github.com/cjwirth/RichEditorView", title: "Github Link")
    }
}

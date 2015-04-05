//
//  TableViewController.swift
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 4/5/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit
import RichEditorView

class RichEditorItem: RichEditorDelegate {
    var editor: RichEditorView

    private(set) var contentHeight: Int = 0 {
        didSet {

        }
    }

    init(html: String) {
        editor = RichEditorView(frame: CGRectMake(0, 0, 320, 1))
        editor.scrollEnabled = false
        editor.setHTML(html)
        editor.delegate = self
    }

    func richEditor(editor: RichEditorView, heightDidChange height: Int) {

    }

    func richEditor(editor: RichEditorView, contentDidChange content: String) { }

    func richEditorTookFocus(editor: RichEditorView) { }
}

class TableViewController: UIViewController {

    var tableView: UITableView!

    var items: [RichEditorItem] = []
    var currentItem: RichEditorItem?

    override func viewDidLoad() {
        super.viewDidLoad()


    }

}

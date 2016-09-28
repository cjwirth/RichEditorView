//
//  RichEditorToolbar.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit

/**
    RichEditorToolbarDelegate is a protocol for the RichEditorToolbar.
    Used to receive actions that need extra work to perform (eg. display some UI)
*/
@objc public protocol RichEditorToolbarDelegate: NSObjectProtocol {

    /**
        Called when the Text Color toolbar item is pressed.
    */
    @objc optional func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar)

    /**
        Called when the Background Color toolbar item is pressed.
    */
    @objc optional func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar)

    /**
        Called when the Insert Image toolbar item is pressed.
    */
    @objc optional func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar)

    /**
        Called when the Insert Link toolbar item is pressed.
    */
    @objc optional func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar)
}


/**
    RichBarButtonItem is a subclass of UIBarButtonItem that takes a callback as opposed to the target-action pattern
*/
open class RichBarButtonItem: UIBarButtonItem {
    open var actionHandler: ((Void) -> Void)?
    
    public convenience init(image: UIImage? = nil, handler: ((Void) -> Void)? = nil) {
        self.init(image: image, style: .plain, target: nil, action: nil)
        target = self
        action = #selector(RichBarButtonItem.buttonWasTapped)
        actionHandler = handler
    }
    
    public convenience init(title: String = "", handler: ((Void) -> Void)? = nil) {
        self.init(title: title, style: .plain, target: nil, action: nil)
        target = self
        action = #selector(RichBarButtonItem.buttonWasTapped)
        actionHandler = handler
    }
    
    func buttonWasTapped() {
        actionHandler?()
    }
}

/**
    RichEditorToolbar is UIView that contains the toolbar for actions that can be performed on a RichEditorView
*/
open class RichEditorToolbar: UIView {

    /**
        The delegate to receive events that cannot be automatically completed
    */
    open weak var delegate: RichEditorToolbarDelegate?

    /**
        A reference to the RichEditorView that it should be performing actions on
    */
    open weak var editor: RichEditorView?

    /**
        The list of options to be displayed on the toolbar
    */
    open var options: [RichEditorOption] = [] {
        didSet {
            updateToolbar()
        }
    }

    fileprivate var toolbarScroll: UIScrollView
    fileprivate var toolbar: UIToolbar
    fileprivate var backgroundToolbar: UIToolbar
    
    public override init(frame: CGRect) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        self.autoresizingMask = .flexibleWidth

        backgroundToolbar.frame = self.bounds
        backgroundToolbar.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        toolbar.autoresizingMask = .flexibleWidth
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)

        toolbarScroll.frame = self.bounds
        toolbarScroll.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        toolbarScroll.showsHorizontalScrollIndicator = false
        toolbarScroll.showsVerticalScrollIndicator = false
        toolbarScroll.backgroundColor = UIColor.clear

        toolbarScroll.addSubview(toolbar)

        addSubview(backgroundToolbar)
        addSubview(toolbarScroll)
        updateToolbar()
    }
    
    fileprivate func updateToolbar() {
        var buttons = [UIBarButtonItem]()
        for option in options {
            if let image = option.image() {
                let button = RichBarButtonItem(image: image) { [weak self] in  option.action(self) }
                buttons.append(button)
            } else {
                let title = option.title()
                let button = RichBarButtonItem(title: title) { [weak self] in option.action(self) }
                buttons.append(button)
            }

        }
        toolbar.items = buttons

        let defaultIconWidth: CGFloat = 22
        let barButtonItemMargin: CGFloat = 11
        let width: CGFloat = buttons.reduce(0) {sofar, new in
            if let view = new.value(forKey: "view") as? UIView {
                return sofar + view.frame.size.width + barButtonItemMargin
            } else {
                return sofar + (defaultIconWidth + barButtonItemMargin)
            }
        }
        
        if width < self.frame.size.width {
            toolbar.frame.size.width = self.frame.size.width
        } else {
            toolbar.frame.size.width = width
        }
        toolbar.frame.size.height = 44
        toolbarScroll.contentSize.width = width
    }
    
}

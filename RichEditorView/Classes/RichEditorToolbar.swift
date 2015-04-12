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
public protocol RichEditorToolbarDelegate: class {

    /**
        Called when the Text Color toolbar item is pressed.
    */
    func richEditorToolbarChangeTextColor(toolbar: RichEditorToolbar)

    /**
        Called when the Background Color toolbar item is pressed.
    */
    func richEditorToolbarChangeBackgroundColor(toolbar: RichEditorToolbar)

    /**
        Called when the Insert Image toolbar item is pressed.
    */
    func richEditorToolbarInsertImage(toolbar: RichEditorToolbar)

    /**
        Called when the Isert Link toolbar item is pressed.
    */
    func richEditorToolbarChangeInsertLink(toolbar: RichEditorToolbar)
}


/**
    RichBarButtonItem is a subclass of UIBarButtonItem that takes a callback as opposed to the target-action pattern
*/
public class RichBarButtonItem: UIBarButtonItem {
    public var actionHandler: (Void -> Void)?
    
    public convenience init(image: UIImage? = nil, handler: (Void -> Void)? = nil) {
        self.init(image: image, style: .Plain, target: nil, action: nil)
        target = self
        action = Selector("buttonWasTapped")
        actionHandler = handler
    }
    
    public convenience init(title: String = "", handler: (Void -> Void)? = nil) {
        self.init(title: title, style: .Plain, target: nil, action: nil)
        target = self
        action = Selector("buttonWasTapped")
        actionHandler = handler
    }
    
    func buttonWasTapped() {
        actionHandler?()
    }
}

/**
    RichEditorToolbar is UIView that contains the toolbar for actions that can be performed on a RichEditorView
*/
public class RichEditorToolbar: UIView {

    /**
        The delegate to receive events that cannot be automatically completed
    */
    public weak var delegate: RichEditorToolbarDelegate?

    /**
        A reference to the RichEditorView that it should be performing actions on
    */
    public weak var editor: RichEditorView?

    /**
        The list of options to be displayed on the toolbar
    */
    public var options: [RichEditorOption] = [] {
        didSet {
            updateToolbar()
        }
    }

    private var toolbarScroll: UIScrollView
    private var toolbar: UIToolbar
    private var backgroundToolbar: UIToolbar
    
    public override init(frame: CGRect) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(frame: frame)
        setup()
    }
    
    public required init(coder aDecoder: NSCoder) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.autoresizingMask = .FlexibleWidth

        backgroundToolbar.frame = self.bounds
        backgroundToolbar.autoresizingMask = .FlexibleHeight | .FlexibleWidth

        toolbar.autoresizingMask = .FlexibleWidth
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .Any)

        toolbarScroll.frame = self.bounds
        toolbarScroll.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        toolbarScroll.showsHorizontalScrollIndicator = false
        toolbarScroll.showsVerticalScrollIndicator = false
        toolbarScroll.backgroundColor = UIColor.clearColor()

        toolbarScroll.addSubview(toolbar)

        self.addSubview(backgroundToolbar)
        self.addSubview(toolbarScroll)
    }
    
    private func updateToolbar() {
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
        var width: CGFloat = buttons.reduce(0) {sofar, new in
            if let view = new.valueForKey("view") as? UIView {
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

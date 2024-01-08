//
//  RichEditorToolbar.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit

/// RichEditorToolbarDelegate is a protocol for the RichEditorToolbar.
/// Used to receive actions that need extra work to perform (eg. display some UI)
@objc public protocol RichEditorToolbarDelegate: class {

    /// Called when the Text Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar)

    /// Called when the Background Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar)

    /// Called when the Insert Image toolbar item is pressed.
    @objc optional func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar)

    /// Called when the Insert Link toolbar item is pressed.
    @objc optional func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar)
}

/// RichBarButtonItem is a subclass of UIBarButtonItem that takes a callback as opposed to the target-action pattern
@objcMembers open class RichBarButtonItem: UIBarButtonItem {
    open var actionHandler: (() -> Void)?
    
    public convenience init(image: UIImage? = nil, handler: (() -> Void)? = nil) {
        self.init(image: image, style: .plain, target: nil, action: nil)
        target = self
        action = #selector(RichBarButtonItem.buttonWasTapped)
        actionHandler = handler
    }
    
    public convenience init(title: String = "", handler: (() -> Void)? = nil) {
        self.init(title: title, style: .plain, target: nil, action: nil)
        target = self
        action = #selector(RichBarButtonItem.buttonWasTapped)
        actionHandler = handler
    }
    
    @objc func buttonWasTapped() {
        actionHandler?()
    }
}

/// RichEditorToolbar is UIView that contains the toolbar for actions that can be performed on a RichEditorView
@objcMembers open class RichEditorToolbar: UIView {

    /// The delegate to receive events that cannot be automatically completed
    open weak var delegate: RichEditorToolbarDelegate?

    /// A reference to the RichEditorView that it should be performing actions on
    open weak var editor: RichEditorView?

    /// The list of options to be displayed on the toolbar
    open var options: [RichEditorOption] = [] {
        didSet {
            updateToolbar()
        }
    }

    /// The tint color to apply to the toolbar background.
    open var barTintColor: UIColor? {
        get { return backgroundToolbar.barTintColor }
        set { backgroundToolbar.barTintColor = newValue }
    }

    private var toolbarScroll: UIScrollView
    private var defautToolbar: UIToolbar
    private var backgroundToolbar: UIToolbar
    public var searchBar = UISearchBar()
     
    lazy var headlineToolbar: UIToolbar = {
    let bar = UIToolbar(frame: CGRect(x: 0, y:0, width: bounds.width, height: 44))
    var buttons = [UIBarButtonItem]()
    let opt = RichEditorHeadingOption.all
    let headLineBar = createToolBar(bar: bar,options: opt)
    return headLineBar
    }()
    
    lazy var linkToolbar: UIToolbar = {
        let bar = UIToolbar(frame: CGRect(x: 0, y:0, width: bounds.width, height: 44))
        bar.isHidden = true
        bar.alpha = 0
        
        let option = RichEditorDefaultOption.pasteLink
        let button: RichBarButtonItem
        
        let handler = { [weak self] in
            if let strongSelf = self {
                option.action(strongSelf)
            }
        }
        if let image = option.image {
            button = RichBarButtonItem(image: image, handler: handler)
        } else {
            let title = option.title
            button = RichBarButtonItem(title: title, handler: handler)
        }
         
        let negativeSeperator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSeperator.width = 12
        searchBar.frame = CGRect(x: 0, y:0, width: bounds.width - 70, height: 44)
        searchBar.barTintColor = .lightGray
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        searchBar.placeholder = "paste a link e.g., https://www.wikipedia.org"
        let searchBarButton = UIBarButtonItem.init(customView: searchBar)
        bar.items = [searchBarButton,negativeSeperator,button]
        toolbarScroll.addSubview(bar)
       return bar
    }()
  
    lazy var fontToolbar: UIToolbar = {
       let bar = UIToolbar(frame: CGRect(x: 0, y:0, width: 820, height: 44))
       var buttons = [UIBarButtonItem]()
       let opt = RichEditorFontOption.all
       let fontBar = createToolBar(bar: bar,options: opt)
       return fontBar
    }()
    
    
    lazy var allignmentToolbar: UIToolbar = {
       let bar = UIToolbar(frame: CGRect(x: 0, y:0, width: bounds.width, height: 44))
       var buttons = [UIBarButtonItem]()
       let opt = RichEditorAllignmentOption.all
       let alignBar = createToolBar(bar: bar,options: opt)
       return alignBar
    }()
    
    lazy var sizeToolbar: UIToolbar = {
        
        var width:CGFloat = 400
        if bounds.width > 400 {
            width = bounds.width
        }

       let bar = UIToolbar(frame: CGRect(x: 0, y:0, width: width, height: 44))
       var buttons = [UIBarButtonItem]()
       let opt = RichEditorTextSizeOption.all
       let fontBar = createToolBar(bar: bar,options: opt)
       return fontBar
    }()
    
    
    func createToolBar(bar: UIToolbar,options: [RichEditorOption]) -> UIToolbar {
        bar.isHidden = true
        bar.autoresizingMask = .flexibleWidth
        bar.alpha = 0
        var buttons = [UIBarButtonItem]()
        for option in options {
            let handler = { [weak self] in
                if let strongSelf = self {
                    option.action(strongSelf)
                }
            }
            if let image = option.image {
                let button = RichBarButtonItem(image: image, handler: handler)
                buttons.append(button)
            } else {
                let title = option.title
                let button = RichBarButtonItem(title: title, handler: handler)
                buttons.append(button)
            }
        }
        bar.items = buttons
        toolbarScroll.addSubview(bar)
       return bar
    }
    
    public func resetBars() {
        let bars = [sizeToolbar,allignmentToolbar,fontToolbar,headlineToolbar, linkToolbar]
        bars.forEach({
            $0.isHidden = true
            $0.alpha = 0
        })
        defautToolbar.isHidden = false
        toolbarScroll.contentSize.width = 750
        toolbarScroll.setContentOffset(.zero, animated: true)
    }
     
    func toggleBars(bar: UIToolbar) {
        toolbarScroll.setContentOffset(.zero, animated: true)
             if bar.isHidden {
                bar.alpha = 1
                toolbarScroll.contentSize.width = bar.bounds.size.width
            } else {
                bar.alpha = 0
                // this should be defautToolbar.frame.width, temp fix for bug:
                toolbarScroll.contentSize.width = 750
            }
                bar.isHidden = !bar.isHidden
                defautToolbar.isHidden = !bar.isHidden
    }
    
    public override init(frame: CGRect) {
        toolbarScroll = UIScrollView()
        defautToolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        toolbarScroll = UIScrollView()
        defautToolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        autoresizingMask = .flexibleWidth
        backgroundColor = .clear

        backgroundToolbar.frame = bounds
        backgroundToolbar.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        defautToolbar.autoresizingMask = .flexibleWidth
        defautToolbar.backgroundColor = .clear
        defautToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        defautToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)

        toolbarScroll.frame = bounds
        toolbarScroll.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        toolbarScroll.showsHorizontalScrollIndicator = false
        toolbarScroll.showsVerticalScrollIndicator = false
        toolbarScroll.backgroundColor = .clear

        toolbarScroll.addSubview(defautToolbar)

        addSubview(backgroundToolbar)
        addSubview(toolbarScroll)
        updateToolbar()
    }
    
    private func updateToolbar() {
        var buttons = [UIBarButtonItem]()
        for option in options {
            let handler = { [weak self] in
                if let strongSelf = self {
                    option.action(strongSelf)
                }
            }

            if let image = option.image {
                let button = RichBarButtonItem(image: image, handler: handler)
                buttons.append(button)
            } else {
                let title = option.title
                let button = RichBarButtonItem(title: title, handler: handler)
                buttons.append(button)
            }
        }
        defautToolbar.items = buttons

        let defaultIconWidth: CGFloat = 28
        let barButtonItemMargin: CGFloat = 11
        let width: CGFloat = buttons.reduce(0) {sofar, new in
            if let view = new.value(forKey: "view") as? UIView {
                return sofar + view.frame.size.width + barButtonItemMargin
            } else {
                return sofar + (defaultIconWidth + barButtonItemMargin)
            }
        }
        
        if width < frame.size.width {
            defautToolbar.frame.size.width = frame.size.width
        } else {
            defautToolbar.frame.size.width = width + 10 //padding
        }
        defautToolbar.frame.size.height = 44
        toolbarScroll.contentSize.width = width
    }
    
}

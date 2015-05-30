//
//  RichEditorOptionItem.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit

/**
    A RichEditorOption object is an object that can be displayed in a RichEditorToolbar.
    This protocol is proviced to allow for custom actions not provided in the RichEditorOptions enum
*/
public protocol RichEditorOption {

    /**
        Returns the image to be displayed in the RichEditorToolbar
    */
    func image() -> UIImage?

    /**
        Returns the title of the item.
        If `image()` returns nil, this method will be used for display in the RichEditorToolbar
    */
    func title() -> String

    /**
        The action to be evoked when the action is tapped
    
        :param: editor The RichEditorToolbar that the RichEditorOption was being displayed in when tapped.
                       Contains a reference to the `editor` RichEditorView to perform actions on
    */
    func action(editor: RichEditorToolbar?)
}

/**
    RichEditorOptionItem is a concrete implementation of RichEditorOption
    It can be used as a configuration object for custom objects to be shown on a RichEditorToolbar
*/
public struct RichEditorOptionItem: RichEditorOption {

    /**
        The image that should be shown when displayed in the RichEditorToolbar
    */
    public var itemImage: UIImage?

    /**
        If an `itemImage` is not specified, this is used in display
    */
    public var itemTitle: String

    /**
        The action to be performed when tapped
    */
    public var itemAction: (RichEditorToolbar? -> Void)

    public init(image: UIImage?, title: String, action: (RichEditorToolbar? -> Void)) {
        itemImage = image
        itemTitle = title
        itemAction = action
    }
    
    // MARK: RichEditorOption
    
    public func image() -> UIImage? {
        return itemImage
    }
    
    public func title() -> String {
        return itemTitle
    }
    
    public func action(toolbar: RichEditorToolbar?) {
        itemAction(toolbar)
    }
}

/**
    RichEditorOptions is an enum of standard editor actions
*/
public enum RichEditorOptions: RichEditorOption {

    case Clear
    case Undo
    case Redo
    case Bold
    case Italic
    case Subscript
    case Superscript
    case Strike
    case Underline
    case TextColor
    case TextBackgroundColor
    case Header(Int)
    case Indent
    case Outdent
    case OrderedList
    case UnorderedList
    case AlignLeft
    case AlignCenter
    case AlignRight
    case Image
    case Link
    
    public static func all() -> [RichEditorOption] {
        return [
            Clear,
            Undo, Redo, Bold, Italic,
            Subscript, Superscript, Strike, Underline,
            TextColor, TextBackgroundColor,
            Header(1), Header(2), Header(3), Header(4), Header(5), Header(6),
            Indent, Outdent, OrderedList, UnorderedList,
            AlignLeft, AlignCenter, AlignRight, Image, Link
        ]
    }
    
    // MARK: RichEditorOption
    
    public func image() -> UIImage? {
        var name = ""
        switch self {
        case .Clear: name = "clear"
        case .Undo: name = "undo"
        case .Redo: name = "redo"
        case .Bold: name = "bold"
        case .Italic: name = "italic"
        case .Subscript: name = "subscript"
        case .Superscript: name = "superscript"
        case .Strike: name = "strikethrough"
        case .Underline: name = "underline"
        case .TextColor: name = "text_color"
        case .TextBackgroundColor: name = "bg_color"
        case .Header(let h): name = "h\(h)"
        case .Indent: name = "indent"
        case .Outdent: name = "outdent"
        case .OrderedList: name = "ordered_list"
        case .UnorderedList: name = "unordered_list"
        case .AlignLeft: name = "justify_left"
        case .AlignCenter: name = "justify_center"
        case .AlignRight: name = "justify_right"
        case .Image: name = "insert_image"
        case .Link: name = "insert_link"
        }
        
        let bundle = NSBundle(forClass: RichEditorToolbar.self)
        return UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
    }
    
    public func title() -> String {
        switch self {
        case .Clear: return NSLocalizedString("Clear", comment: "")
        case .Undo: return NSLocalizedString("Undo", comment: "")
        case .Redo: return NSLocalizedString("Redo", comment: "")
        case .Bold: return NSLocalizedString("Bold", comment: "")
        case .Italic: return NSLocalizedString("Italic", comment: "")
        case .Subscript: return NSLocalizedString("Sub", comment: "")
        case .Superscript: return NSLocalizedString("Super", comment: "")
        case .Strike: return NSLocalizedString("Strike", comment: "")
        case .Underline: return NSLocalizedString("Underline", comment: "")
        case .TextColor: return NSLocalizedString("Color", comment: "")
        case .TextBackgroundColor: return NSLocalizedString("BG Color", comment: "")
        case .Header(let h): return NSLocalizedString("H\(h)", comment: "")
        case .Indent: return NSLocalizedString("Indent", comment: "")
        case .Outdent: return NSLocalizedString("Outdent", comment: "")
        case .OrderedList: return NSLocalizedString("Ordered List", comment: "")
        case .UnorderedList: return NSLocalizedString("Unordered List", comment: "")
        case .AlignLeft: return NSLocalizedString("Left", comment: "")
        case .AlignCenter: return NSLocalizedString("Center", comment: "")
        case .AlignRight: return NSLocalizedString("Right", comment: "")
        case .Image: return NSLocalizedString("Image", comment: "")
        case .Link: return NSLocalizedString("Link", comment: "")
        }
    }
    
    public func action(toolbar: RichEditorToolbar?) {
        if let toolbar = toolbar {
            switch self {
            case .Clear: toolbar.editor?.removeFormat()
            case .Undo: toolbar.editor?.undo()
            case .Redo: toolbar.editor?.redo()
            case .Bold: toolbar.editor?.bold()
            case .Italic: toolbar.editor?.italic()
            case .Subscript: toolbar.editor?.subscriptText()
            case .Superscript: toolbar.editor?.superscript()
            case .Strike: toolbar.editor?.strikethrough()
            case .Underline: toolbar.editor?.underline()
            case .TextColor: toolbar.delegate?.richEditorToolbarChangeTextColor(toolbar)
            case .TextBackgroundColor: toolbar.delegate?.richEditorToolbarChangeBackgroundColor(toolbar)
            case .Header(let h): toolbar.editor?.header(h)
            case .Indent: toolbar.editor?.indent()
            case .Outdent: toolbar.editor?.outdent()
            case .OrderedList: toolbar.editor?.orderedList()
            case .UnorderedList: toolbar.editor?.unorderedList()
            case .AlignLeft: toolbar.editor?.alignLeft()
            case .AlignCenter: toolbar.editor?.alignCenter()
            case .AlignRight: toolbar.editor?.alignRight()
            case .Image: toolbar.delegate?.richEditorToolbarInsertImage(toolbar)
            case .Link: toolbar.delegate?.richEditorToolbarChangeInsertLink(toolbar)
            }
        }
    }
}

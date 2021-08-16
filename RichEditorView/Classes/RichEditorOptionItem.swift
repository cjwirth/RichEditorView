//
//  RichEditorOptionItem.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit

/// A RichEditorOption object is an object that can be displayed in a RichEditorToolbar.
/// This protocol is proviced to allow for custom actions not provided in the RichEditorOptions enum.
public protocol RichEditorOption {

    /// The image to be displayed in the RichEditorToolbar.
    var image: UIImage? { get }

    /// The title of the item.
    /// If `image` is nil, this will be used for display in the RichEditorToolbar.
    var title: String { get }

    /// The action to be evoked when the action is tapped
    /// - parameter editor: The RichEditorToolbar that the RichEditorOption was being displayed in when tapped.
    ///                     Contains a reference to the `editor` RichEditorView to perform actions on.
    func action(_ editor: RichEditorToolbar)
}

/// RichEditorOptionItem is a concrete implementation of RichEditorOption.
/// It can be used as a configuration object for custom objects to be shown on a RichEditorToolbar.
public struct RichEditorOptionItem: RichEditorOption {

    /// The image that should be shown when displayed in the RichEditorToolbar.
    public var image: UIImage?

    /// If an `itemImage` is not specified, this is used in display
    public var title: String

    /// The action to be performed when tapped
    public var handler: ((RichEditorToolbar) -> Void)

    public init(image: UIImage?, title: String, action: @escaping ((RichEditorToolbar) -> Void)) {
        self.image = image
        self.title = title
        self.handler = action
    }
    
    // MARK: RichEditorOption
    
    public func action(_ toolbar: RichEditorToolbar) {
        handler(toolbar)
    }
}

public enum RichEditorHeadingOption: RichEditorOption {
    
    case back
    case header(Int)

    public static let all: [RichEditorHeadingOption] = [ .back, .header(1), .header(2), .header(3), .header(4), .header(5), .header(6),]
    
    public var image: UIImage? {
        var name = ""
        switch self  {
            case .header(let h): name = "h\(h)"
            case .back: name = "back"
        }
          let bundle = Bundle(for: RichEditorToolbar.self)
          return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
    
    public var title: String  {
        var name = ""
        switch self  {
            case .header(let h): name = "h\(h)"
            case .back: name = "back"
        }
        return name
    }
    
    public func action(_ toolbar: RichEditorToolbar) {
        switch self  {
            case .header(let h): toolbar.editor?.header(h)
            case .back: toolbar.editor?.goBackFromHeadlines()
        }
    }
}

public enum RichEditorTextSizeOption: Int, RichEditorOption {
    
    case back = 0
    case pt8 = 8
    case pt10 = 10
    case pt12 = 12
    case pt14 = 14
    case pt18 = 18
    case pt24 = 24
    case pt36 = 36
    
    public static let all: [RichEditorTextSizeOption] = [ .back, .pt10, .pt12, .pt14, .pt18, .pt24, .pt36,]
    
    public var image: UIImage? {
        if self == .back {
            let bundle = Bundle(for: RichEditorToolbar.self)
            return UIImage(named: "back", in: bundle, compatibleWith: nil)
        } else {
            return nil
        }
    }
    
    public var title: String  {
        if self == .back {
            return "back"
        }
        let str = String(self.rawValue) + "pt "
        return str
    }
    
    public func action(_ toolbar: RichEditorToolbar) {
        toolbar.editor?.setFontSize(self.rawValue)
    }
    
}


public enum RichEditorFontOption: String, RichEditorOption {
    
    case back = "back"
    case Ariel = "Ariel"
    case CourierNew = "CourierNew"
    case Georgia = "Georgia"
    case Impact = "Impact"
    case LucidaConsole = "LucidaConsole"
    case Tahoma = "Tahoma"
    case TimesNewRoman = "TimesNewRoman"
    case Verdana = "Verdana"
    
    public static let all: [RichEditorFontOption] = [
        .back, .Ariel, .CourierNew, .Georgia, .Impact, .LucidaConsole, .Tahoma, .TimesNewRoman, .Verdana,
    ]
    
    public var image: UIImage? {
        if self == .back {
            let bundle = Bundle(for: RichEditorToolbar.self)
            return UIImage(named: "back", in: bundle, compatibleWith: nil)
        }
        return nil
    }
    
    public var title: String  {
        return self.rawValue
    }
    
    public func action(_ toolbar: RichEditorToolbar) {
        toolbar.editor?.setFont(self.rawValue)
    }
     
}

public enum RichEditorAllignmentOption: RichEditorOption {
    
    case back
    case indent
    case outdent
    case orderedList
    case unorderedList
    case alignLeft
    case alignCenter
    case alignRight
    case justify
 
    
    public static let all: [RichEditorAllignmentOption] = [
        .back, .indent, .outdent, .orderedList, .unorderedList,
        .alignLeft, .alignCenter, .alignRight,.justify,
    ]
    
    public var image: UIImage? {
        var name = ""
        switch  self  {
        case .back: name = "back"
        case .indent: name = "indent"
        case .outdent: name = "outdent"
        case .orderedList: name = "ordered_list"
        case .unorderedList: name = "unordered_list"
        case .alignLeft: name = "justify_left"
        case .alignCenter: name = "justify_center"
        case .alignRight: name = "justify_right"
        case .justify: name = "justify_full"
        }
        let bundle = Bundle(for: RichEditorToolbar.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
    
    public var title: String  {
        switch  self  {
        case .back: return NSLocalizedString("back", comment: "")
        case .indent: return NSLocalizedString("Indent", comment: "")
        case .outdent: return NSLocalizedString("Outdent", comment: "")
        case .orderedList: return NSLocalizedString("Ordered List", comment: "")
        case .unorderedList: return NSLocalizedString("Unordered List", comment: "")
        case .alignLeft: return NSLocalizedString("Left", comment: "")
        case .alignCenter: return NSLocalizedString("Center", comment: "")
        case .alignRight: return NSLocalizedString("Right", comment: "")
        case .justify: return NSLocalizedString("Justify", comment: "")
        }
    }
    
    public func action(_ toolbar: RichEditorToolbar) {
        switch  self  {
        case .back: toolbar.editor?.goBackFromAllignments()
        case .indent: toolbar.editor?.indent()
        case .outdent: toolbar.editor?.outdent()
        case .orderedList: toolbar.editor?.orderedList()
        case .unorderedList: toolbar.editor?.unorderedList()
        case .alignLeft: toolbar.editor?.alignLeft()
        case .alignCenter: toolbar.editor?.alignCenter()
        case .alignRight: toolbar.editor?.alignRight()
        case .justify: toolbar.editor?.justifyFull()
        }
    }
     
}
/// RichEditorOptions is an enum of standard editor actions
public enum RichEditorDefaultOption: RichEditorOption {

    case clear
    case undo
    case redo
    case bold
    case italic
    case size
    case header
    case font
    case blockquote
    case code
    case `subscript`
    case superscript
    case strike
    case underline
    case textColor
    case textBackgroundColor
    case allignment
    case image
    case link
    
    public static let all: [RichEditorDefaultOption] = [
        .clear, .undo, .redo, .bold, .italic, .header, .size, .font,
        .subscript, .superscript, .strike, .underline,
        .textColor, .textBackgroundColor, .allignment,
        .code, .blockquote,.image, .link
    ]

    // MARK: RichEditorOption

    public var image: UIImage? {
        var name = ""
        switch self {
        case .clear: name = "clear"
        case .code: name = "code"
        case .blockquote: name = "blockQuote"
        case .undo: name = "undo"
        case .redo: name = "redo"
        case .bold: name = "bold"
        case .italic: name = "italic"
        case .subscript: name = "subscript"
        case .superscript: name = "superscript"
        case .strike: name = "strikethrough"
        case .underline: name = "underline"
        case .textColor: name = "text_color"
        case .textBackgroundColor: name = "bg_color"
        case .header: name = "h"
       
        case .image: name = "insert_image"
        case .link: name = "insert_link"
        case .size: name = "size"
        case .font: name = "f"
        case .allignment: name = "justify"
        }
        
        let bundle = Bundle(for: RichEditorToolbar.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
    
    public var title: String {
        switch self {
        case .clear: return NSLocalizedString("Clear", comment: "")
        case .undo: return NSLocalizedString("Undo", comment: "")
        case .redo: return NSLocalizedString("Redo", comment: "")
        case .code: return NSLocalizedString("Code Block", comment: "")
        case .blockquote: return NSLocalizedString("blockQuote", comment: "")
        case .bold: return NSLocalizedString("Bold", comment: "")
        case .italic: return NSLocalizedString("Italic", comment: "")
        case .subscript: return NSLocalizedString("Sub", comment: "")
        case .superscript: return NSLocalizedString("Super", comment: "")
        case .strike: return NSLocalizedString("Strike", comment: "")
        case .underline: return NSLocalizedString("Underline", comment: "")
        case .textColor: return NSLocalizedString("Color", comment: "")
        case .textBackgroundColor: return NSLocalizedString("BG Color", comment: "")
        case .header: return NSLocalizedString("H", comment: "")
        case .allignment: return NSLocalizedString("Allignment", comment: "")
        case .image: return NSLocalizedString("Image", comment: "")
        case .link: return NSLocalizedString("Link", comment: "")
        case .size: return NSLocalizedString("Size", comment: "")
        case .font: return NSLocalizedString("Font", comment: "")
        }
    }
    
    public func action(_ toolbar: RichEditorToolbar) {
        switch self {
        case .clear: toolbar.editor?.removeFormat()
        case .undo: toolbar.editor?.undo()
        case .redo: toolbar.editor?.redo()
        case .code: toolbar.editor?.setCode()
        case .bold: toolbar.editor?.bold()
        case .italic: toolbar.editor?.italic()
        case .subscript: toolbar.editor?.subscriptText()
        case .superscript: toolbar.editor?.superscript()
        case .strike: toolbar.editor?.strikethrough()
        case .underline: toolbar.editor?.underline()
        case .textColor: toolbar.delegate?.richEditorToolbarChangeTextColor?(toolbar)
        case .textBackgroundColor: toolbar.delegate?.richEditorToolbarChangeBackgroundColor?(toolbar)
        case .header: toolbar.editor?.showHeader()
        case .allignment: toolbar.editor?.showAllignments()
        case .image: toolbar.delegate?.richEditorToolbarInsertImage?(toolbar)
        case .link: toolbar.delegate?.richEditorToolbarInsertLink?(toolbar)
        case .size: toolbar.editor?.showTextSize()
        case .font: toolbar.editor?.showFonts()
        case .blockquote: toolbar.editor?.blockquote()
        }
    }
}

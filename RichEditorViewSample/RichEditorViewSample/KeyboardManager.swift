//
//  KeyboardManager.swift
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 4/5/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit
import RichEditorView

/**
    KeyboardManager is a class that takes care of showing and hiding the RichEditorToolbar when the keyboard is shown.
    As opposed to having this logic in multiple places, it is encapsulated in here. All that needs to change is the parent view.
*/
class KeyboardManager: NSObject {

    /**
        The parent view that the toolbar should be added to.
        Should normally be the top-level view of a UIViewController
    */
    weak var view: UIView?

    /**
        The toolbar that will be shown and hidden.
    */
    var toolbar: RichEditorToolbar

    init(view: UIView) {
        self.view = view
        toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 44))
        toolbar.options = RichEditorOptions.all()
    }

    /**
        Starts monitoring for keyboard notifications in order to show/hide the toolbar
    */
    func beginMonitoring() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyboardManager.keyboardWillShowOrHide(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyboardManager.keyboardWillShowOrHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    /**
        Stops monitoring for keyboard notifications
    */
    func stopMonitoring() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    /**
        Called when a keyboard notification is recieved. Takes are of handling the showing or hiding of the toolbar
    */
    func keyboardWillShowOrHide(notification: NSNotification) {

        let info = notification.userInfo ?? [:]
        let duration = NSTimeInterval((info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.25)
        let curve = UInt((info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.unsignedLongValue ?? 0)
        let options = UIViewAnimationOptions(rawValue: curve)
        let keyboardRect = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() ?? CGRectZero


        if notification.name == UIKeyboardWillShowNotification {
            self.view?.addSubview(self.toolbar)
            UIView.animateWithDuration(duration, delay: 0, options: options, animations: {
                if let view = self.view {
                    self.toolbar.frame.origin.y = view.frame.height - (keyboardRect.height + self.toolbar.frame.height)
                }
            }, completion: nil)


        } else if notification.name == UIKeyboardWillHideNotification {
            UIView.animateWithDuration(duration, delay: 0, options: options, animations: {
                if let view = self.view {
                    self.toolbar.frame.origin.y = view.frame.height
                }
            }, completion: nil)
        }
    }
}

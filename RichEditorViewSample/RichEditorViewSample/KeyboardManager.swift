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
@objcMembers class KeyboardManager: NSObject {

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
        toolbar.options = RichEditorDefaultOption.all
    }

    /**
        Starts monitoring for keyboard notifications in order to show/hide the toolbar
    */
    func beginMonitoring() {
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardManager.keyboardWillShowOrHide(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardManager.keyboardWillShowOrHide(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    /**
        Stops monitoring for keyboard notifications
    */
    func stopMonitoring() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    /**
        Called when a keyboard notification is recieved. Takes are of handling the showing or hiding of the toolbar
    */
    @objc func keyboardWillShowOrHide(_ notification: Notification) {

        let info = (notification as NSNotification).userInfo ?? [:]
        let duration = TimeInterval((info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.25)
        let curve = UInt((info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0)
        let options = UIViewAnimationOptions(rawValue: curve)
        let keyboardRect = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero


        if notification.name == NSNotification.Name.UIKeyboardWillShow {
            self.view?.addSubview(self.toolbar)
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                if let view = self.view {
                    self.toolbar.frame.origin.y = view.frame.height - (keyboardRect.height + self.toolbar.frame.height)
                }
            }, completion: nil)


        } else if notification.name == NSNotification.Name.UIKeyboardWillHide {
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                if let view = self.view {
                    self.toolbar.frame.origin.y = view.frame.height
                }
            }, completion: nil)
        }
    }
}

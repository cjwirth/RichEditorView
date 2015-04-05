//
//  KeyboardManager.swift
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 4/5/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit
import RichEditorView

class KeyboardManager: NSObject {

    weak var view: UIView?
    var toolbar: RichEditorToolbar

    init(view: UIView) {
        self.view = view
        toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 44))
        toolbar.options = RichEditorOptions.all().map { $0 as RichEditorOption }
    }

    func beginMonitoring() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowOrHide:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowOrHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    func stopMonitoring() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardWillShowOrHide(notification: NSNotification) {

        let info = notification.userInfo ?? [:]
        let duration = NSTimeInterval((info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.25)
        let curve = UInt((info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.unsignedLongValue ?? 0)
        let options = UIViewAnimationOptions(curve)
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

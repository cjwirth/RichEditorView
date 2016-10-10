//
//  UIView+Responder.swift
//
//  Created by Caesar Wirth on 11/18/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit

extension UIView {

    /**
        Returns true if the view or one of its subviews is the first responder.
        Performs a depth-first search on the subviews, so it can potentially be a heavy operation.
    */
    internal var containsFirstResponder: Bool {
        if isFirstResponder { return true }
        for view in subviews {
            if view.containsFirstResponder { return true }
        }
        return false
    }

}

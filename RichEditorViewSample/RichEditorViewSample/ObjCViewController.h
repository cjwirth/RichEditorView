//
//  ObjCViewController.h
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 9/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RichEditorView, KeyboardManager;

@interface ObjCViewController : UIViewController
@property (nonatomic, strong) IBOutlet RichEditorView *editorView;
@property (nonatomic, strong) IBOutlet UITextView *htmlTextView;

// The keyboardManager allows us to display the toolbar
// However, some of the features of the RichEditorToolbar are not supported from Objective-C
@property (nonatomic, strong) KeyboardManager *keyboardManager;
@end

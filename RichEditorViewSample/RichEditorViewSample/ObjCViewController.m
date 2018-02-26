//
//  ObjCViewController.m
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 9/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

#import "ObjCViewController.h"
#import <RichEditorView/RichEditorView-Swift.h>
#import "RichEditorViewSample-Swift.h"

@interface ObjCViewController() <RichEditorDelegate>
@end

@implementation ObjCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.editorView.delegate = self;
    self.editorView.placeholder = @"Type some text...";

    self.keyboardManager = [[KeyboardManager alloc] initWithView:self.view];
    self.keyboardManager.toolbar.editor = self.editorView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.keyboardManager beginMonitoring];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.keyboardManager stopMonitoring];
}

//------------------------------------------------------------------------------
#pragma mark - RichEditorViewDelegate

- (void)richEditor:(RichEditorView * __nonnull)editor contentDidChange:(NSString * __nonnull)content {
    if (content.length == 0) {
        self.htmlTextView.text = @"HTML Preview";
    } else {
        self.htmlTextView.text = content;
    }
}

@end

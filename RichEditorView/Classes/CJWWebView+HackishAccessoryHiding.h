//
//  CJWWebView+HackishAccessoryHiding.h
//
//  Created by Caesar Wirth on 3/30/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

#import <UIKit/UIKit.h>

// Credit to this extension goes to bjhomes
// https://gist.github.com/bjhomer/2048571
// Bundled inside to add a vendored prefix so as to hopefully not cause naming conflicts
@interface UIWebView (CJWHackishAccessoryHiding)

// When set to YES, the UIWebView will no longer show an inputAccessoryView when they keyboard is shown.
@property (nonatomic, assign) BOOL cjw_hidesInputAccessoryView;
@end
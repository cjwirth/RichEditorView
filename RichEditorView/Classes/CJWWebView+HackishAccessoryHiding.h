//
//  CJWWebView+HackishAccessoryHiding.h
//
//  Created by Caesar Wirth on 3/30/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

#import <UIKit/UIKit.h>

// Inspiration for this extension comes from:
//   - bjhomes: https://gist.github.com/bjhomer/2048571
//   - diegoreymendez: http://stackoverflow.com/a/25415378/1403046
// Bundled inside to add a vendored prefix so as to hopefully not cause naming conflicts
@interface UIWebView (CJWHackishAccessoryHiding)

// Overrides the standard inputAccessoryView
// Set to a custom view to override. Setting to nil will remove it.
@property (nonatomic, strong, nullable) UIView *cjw_inputAccessoryView;

@end
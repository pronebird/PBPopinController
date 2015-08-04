//
//  UIViewController+PopinController.m
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "UIViewController+PopinController.h"
#import "PBPopinController.h"
#import "PBPopinSegue.h"

#import <objc/runtime.h>

const void* PopinControllerKey = &PopinControllerKey;
const void* PopinAccessoryViewKey = &PopinAccessoryViewKey;

@implementation UIViewController (PopinController)

- (PBPopinController*)popinController {
    return objc_getAssociatedObject(self, PopinControllerKey);
}

- (void)setPopinController:(PBPopinController*)popinController {
    objc_setAssociatedObject(self, PopinControllerKey, popinController, OBJC_ASSOCIATION_RETAIN);
}

- (UIView*)popinAccessoryView {
    return objc_getAssociatedObject(self, PopinAccessoryViewKey);
}

- (void)setPopinAccessoryView:(UIView *)popinAccessoryView {
    objc_setAssociatedObject(self, PopinAccessoryViewKey, popinAccessoryView, OBJC_ASSOCIATION_RETAIN);
}

@end

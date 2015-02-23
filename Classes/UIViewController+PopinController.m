//
//  UIViewController+PopinController.m
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "UIViewController+PopinController.h"
#import "PBPopinController.h"
#import <objc/runtime.h>

const void* PopinControllerKey = &PopinControllerKey;

@implementation UIViewController (PopinController)

- (PBPopinController*)popinController {
    return objc_getAssociatedObject(self, PopinControllerKey);
}

- (void)setPopinController:(PBPopinController*)popinController {
    objc_setAssociatedObject(self, PopinControllerKey, popinController, OBJC_ASSOCIATION_RETAIN);
}

@end

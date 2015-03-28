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

static void PBSwizzleMethod(Class c, SEL original, SEL alternate) {
    Method origMethod = class_getInstanceMethod(c, original);
    Method newMethod = class_getInstanceMethod(c, alternate);
    
    if(class_addMethod(c, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, alternate, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

@implementation UIViewController (PopinController)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PBSwizzleMethod(self, @selector(prepareForSegue:sender:), @selector(pb_prepareForSegue:sender:));
    });
}

- (void)pb_prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue isKindOfClass:PBPopinSegue.class] && [sender isKindOfClass:UIView.class]) {
        ((PBPopinSegue *)segue).sender = sender;
    }
    
    [self pb_prepareForSegue:segue sender:sender];
}

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

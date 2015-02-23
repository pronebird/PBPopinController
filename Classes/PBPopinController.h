//
//  PBPopinController.h
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString* const PBPopinControllerWillAppearNotification;
extern NSString* const PopinControllerDidAppearNotification;
extern NSString* const PBPopinControllerWillDisappearNotification;
extern NSString* const PBPopinControllerDidDisappearNotification;

@interface PBPopinController : NSObject

@property (weak, readonly) UIViewController* sourceViewController;
@property (readonly) UIViewController* contentViewController;

@property (readonly) BOOL presented;

+ (instancetype)sharedPopinController;

- (void)presentWithContentViewController:(UIViewController*)presentedViewController
                      fromViewController:(UIViewController*)sourceViewController
                                animated:(BOOL)animated
                              completion:(void(^)(void))completion;
- (void)dismissAnimated:(BOOL)animated completion:(void(^)(void))completion;

@end

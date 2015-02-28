//
//  PBPopinController.h
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString* const PBPopinControllerWillAppearNotification;
extern NSString* const PBPopinControllerDidAppearNotification;
extern NSString* const PBPopinControllerWillDisappearNotification;
extern NSString* const PBPopinControllerDidDisappearNotification;

@interface PBPopinController : NSObject

/**
 *  A source view controller that requested presentation
 */
@property (weak, readonly) UIViewController* sourceViewController;

/**
 *  A content view controller displayed in popin
 */
@property (readonly) UIViewController* contentViewController;

/**
 *  Whether popin is currently presented
 */
@property (readonly) BOOL presented;

/**
 * Get shared instance of popin controller
 *
 *  @return an instance of PBPopinController
 */
+ (instancetype)sharedPopinController;

/**
 *  Present popin controller
 *
 *  @param presentedViewController a content controller that will be displayed in popin controller
 *  @param sourceViewController    a source view controller you request presentation from
 *  @param animated                whether to animate transition
 *  @param completion              a completion handler
 */
- (void)presentWithContentViewController:(UIViewController*)presentedViewController
                      fromViewController:(UIViewController*)sourceViewController
                                animated:(BOOL)animated
                              completion:(void(^)(void))completion;

/**
 *  Dismiss popin controller
 *
 *  @param animated   whether to animate transition
 *  @param completion a completion handler
 */
- (void)dismissAnimated:(BOOL)animated completion:(void(^)(void))completion;

@end

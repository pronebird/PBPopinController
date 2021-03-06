//
//  PBPopinController.h
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+PopinController.h"

/**
 *  A notification sent before controller appears.
 */
extern NSString * const PBPopinControllerWillAppearNotification;

/**
 *  A notification sent after controller appears.
 */
extern NSString * const PBPopinControllerDidAppearNotification;

/**
 *  A notification sent before controller disappears.
 */
extern NSString * const PBPopinControllerWillDisappearNotification;

/**
 *  A notification sent after controller disappears.
 */
extern NSString * const PBPopinControllerDidDisappearNotification;

/**
 *  A key for initial rect in userInfo dictionary.
 */
extern NSString* const PBPopinControllerInitialFrameUserInfoKey;

/**
 *  A key for final rect in userInfo dictionary.
 */
extern NSString * const PBPopinControllerFinalFrameUserInfoKey;

/**
 *  A key for animation duration in userInfo dictionary.
 */
extern NSString* const PBPopinControllerAnimationDurationUserInfoKey;

/**
 *  A key for animation curve in userInfo dictionary.
 */
extern NSString* const PBPopinControllerAnimationCurveUserInfoKey;


/**
 *  @abstract Popin controller.
 */
@interface PBPopinController : NSObject

/**
 *  A source view controller that requested presentation.
 */
@property (weak, readonly) UIViewController* sourceViewController;

/**
 *  A content view controller displayed in popin.
 */
@property (weak, readonly) UIViewController* contentViewController;

/**
 *  Indicates whether popin is presented.
 */
@property (readonly) BOOL presented;

/**
 *  Get shared instance of popin controller.
 *
 *  @return an instance of PBPopinController
 */
+ (instancetype)sharedPopinController;

/**
 *  @abstract Present popin controller modally. This usually creates a backdrop overlay.
 *  @discussion You can call present multiple times, this will replace child controller within presented popin controller.
 *
 *  @param presentedViewController a content controller that will be displayed in popin controller
 *  @param sourceViewController    a source view controller you request presentation from
 *  @param animated                whether to animate transition
 *  @param completion              a completion handler
 */
- (void)presentModalWithContentViewController:(UIViewController*)contentViewController
                           fromViewController:(UIViewController*)sourceViewController
                                     animated:(BOOL)animated
                                   completion:(void(^)(void))completion;

/**
 *  @abstract Present popin controller.
 *  @discussion You can call present multiple times, this will replace child controller within presented popin controller.
 *
 *  @param presentedViewController a content controller that will be displayed in popin controller
 *  @param sourceViewController    a source view controller you request presentation from
 *  @param animated                whether to animate transition
 *  @param completion              a completion handler
 */
- (void)presentWithContentViewController:(UIViewController*)contentViewController
                      fromViewController:(UIViewController*)sourceViewController
                                animated:(BOOL)animated
                              completion:(void(^)(void))completion;

/**
 *  @abstract Dismiss popin controller.
 *  @discussion Make sure you call it only if controller is presented.
 *
 *  @param animated   whether to animate transition
 *  @param completion a completion handler
 */
- (void)dismissAnimated:(BOOL)animated completion:(void(^)(void))completion;

@end

//
//  PBPopinContainerViewController.h
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBPopinContainerViewController : UIViewController

/**
 *  Current content controller.
 */
@property (readonly) UIViewController* contentViewController;

/**
 *  Designated initializer.
 *
 *  @param contentViewController an instance of content view controller or nil
 *
 *  @return an instance of PopinContainerViewController
 */
- (instancetype)initWithContentViewController:(UIViewController*)contentViewController NS_DESIGNATED_INITIALIZER;

/**
 *  Set content view controller.
 *
 *  @param contentViewController an instance of content view controller
 *  @param animated              use animations or not
 *  @param alongsideAnimation    a block that will be called within animation block
 *  @param completion            a handler block called in the end of transition
 */
- (void)setContentViewController:(UIViewController *)contentViewController
                        animated:(BOOL)animated
                alongsideAnimation:(void(^)(void))alongsideAnimation
                      completion:(void(^)(void))completion;

/**
 *  Frame of content view controller when presented.
 *
 *  @param controller a content view controller
 *
 *  @return CGRect
 */
- (CGRect)finalFrameForTransitionView:(UIViewController*)controller;

@end

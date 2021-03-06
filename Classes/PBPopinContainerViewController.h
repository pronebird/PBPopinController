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
@property (nonatomic, readonly) UIViewController* contentViewController;

/**
 *  Source controller.
 *  Used to redirect status bar appearance events.
 */
@property (weak, nonatomic) UIViewController *sourceViewController;

/**
 *  Backdrop view.
 */
@property (nonatomic, readonly) UIView *backdropView;

/**
 *  Whether view controller should show a backdrop view.
 */
@property (nonatomic) BOOL showsBackdrop;

/**
 *  Designated initializer.
 *
 *  @param contentViewController an instance of content view controller or nil
 *
 *  @return an instance of PopinContainerViewController
 */
- (instancetype)initWithContentViewController:(UIViewController*)contentViewController;

/**
 *  Animate backdrop.
 *
 *  @param showsBackdrop fade in or out
 *  @param animated      use animations or not
 */
- (void)setShowsBackdrop:(BOOL)showsBackdrop animated:(BOOL)animated;

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

/**
 *  Frame of content view controller when offscreen.
 *
 *  @param controller a content view controller
 *
 *  @return CGRect
 */
- (CGRect)initialFrameForTransitionView:(UIViewController*)controller;

/**
 *  Animation duration used for transition.
 *
 *  @return NSTimeInterval
 */
- (NSTimeInterval)transitionDuration;

/**
 *  Animation curve used for transition.
 *
 *  @return UIViewAnimationCurve
 */
- (UIViewAnimationCurve)transitionAnimationCurve;

@end

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
 *  Designated initializer
 *
 *  @param contentViewController an instance of content view controller or nil
 *
 *  @return an instance of PopinContainerViewController
 */
- (instancetype)initWithContentViewController:(UIViewController*)contentViewController NS_DESIGNATED_INITIALIZER;

/**
 *  Set content view controller
 *
 *  @param contentViewController an instance of content view controller
 *  @param animated              use animations or not
 *  @param completion            a handler block called in the end of transition
 */
- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated completion:(void(^)(void))completion;

@end

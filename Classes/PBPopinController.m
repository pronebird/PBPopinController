//
//  PBPopinController.m
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "PBPopinController.h"
#import "PBPopinContainerViewController.h"
#import "UIViewController+PopinController.h"

NSString* const PBPopinControllerWillAppearNotification = @"PBPopinControllerWillAppearNotification";
NSString* const PBPopinControllerDidAppearNotification = @"PBPopinControllerDidAppearNotification";
NSString* const PBPopinControllerWillDisappearNotification = @"PBPopinControllerWillDisappearNotification";
NSString* const PBPopinControllerDidDisappearNotification = @"PBPopinControllerDidDisappearNotification";

NSString* const PBPopinControllerInitialFrameUserInfoKey = @"initialFrame";
NSString* const PBPopinControllerFinalFrameUserInfoKey = @"finalFrame";
NSString* const PBPopinControllerAnimationDurationUserInfoKey = @"animationDuration";
NSString* const PBPopinControllerAnimationCurveUserInfoKey = @"animationCurve";

@interface _PBPopinWindow : UIWindow

@property BOOL passthroughTouches;

@end

@implementation _PBPopinWindow

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if(!self.passthroughTouches) {
        return [super pointInside:point withEvent:event];
    }
    
    PBPopinContainerViewController* container = (PBPopinContainerViewController *)self.rootViewController;
    UIView* transitionView = container.contentViewController.view.superview;
    
    if(!CGRectContainsPoint(transitionView.frame, point)) {
        return NO;
    }
    
    return YES;
}

@end

@interface UIViewController ()

@property (readwrite, nonatomic) PBPopinController* popinController;

@end

@interface PBPopinController()

@property PBPopinContainerViewController* containerController;
@property (weak, readwrite) UIViewController* sourceViewController;
@property (weak, readwrite) UIView* sourceView;
@property (readwrite) UIViewController* contentViewController;
@property (readwrite) BOOL presented;
@property UITapGestureRecognizer *dismissTapGestureRecognizer;

@property UIEdgeInsets scrollViewContentInsets;

@end

@implementation PBPopinController

+ (instancetype)sharedPopinController {
    static id popinController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        popinController = [PBPopinController new];
    });
    return popinController;
}

+ (_PBPopinWindow*)popinWindow {
    static _PBPopinWindow* popinWindow;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        popinWindow = [[_PBPopinWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        popinWindow.backgroundColor = [UIColor clearColor];
    });
    return popinWindow;
}

- (void)presentModalWithContentViewController:(UIViewController*)contentViewController
                           fromViewController:(UIViewController*)sourceViewController
                                     animated:(BOOL)animated
                                   completion:(void(^)(void))completion;
{
    [self _presentWithContentViewController:contentViewController
                         fromViewController:sourceViewController
                                      modal:YES
                                   animated:animated
                                 completion:completion];
}

- (void)presentWithContentViewController:(UIViewController*)contentViewController
                      fromViewController:(UIViewController*)sourceViewController
                                animated:(BOOL)animated
                              completion:(void(^)(void))completion {
    [self _presentWithContentViewController:contentViewController
                         fromViewController:sourceViewController
                                      modal:NO
                                   animated:animated
                                 completion:completion];
}

- (void)dismissAnimated:(BOOL)animated completion:(void(^)(void))completion {
    if(!self.presented) {
        if(completion) {
            completion();
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [self _sendControllerWillDisappearNotification:animated];
    
    self.presented = NO;
    [self _removeDismissOnScrollHandler];
    [self _removeDismissOnBackdropTap];
    
    [self.containerController setContentViewController:nil
                                              animated:animated
                                    alongsideAnimation:^{
                                        __strong typeof(weakSelf) strongSelf = weakSelf;
                                        
                                        // fade backdrop
                                        strongSelf.containerController.showsBackdrop = NO;
                                    } completion:^{
                                        __strong typeof(weakSelf) strongSelf = weakSelf;
                                        
                                        // check if still dismissed
                                        if(!strongSelf.presented) {
                                            [strongSelf.class popinWindow].rootViewController = nil;
                                            strongSelf.containerController = nil;
                                            strongSelf.sourceView = nil;
                                            strongSelf.contentViewController.popinController = nil;
                                            
                                            [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
                                            [strongSelf _hidePopinWindow];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:PBPopinControllerDidDisappearNotification object:nil];
                                        }
                                        
                                        if(completion) {
                                            completion();
                                        }
                                    }];
}

#pragma mark - Private

- (void)_showPopinWindow {
    [self.class popinWindow].hidden = NO;
    [[self.class popinWindow] makeKeyAndVisible];
}

- (void)_hidePopinWindow {
    [self.class popinWindow].hidden = YES;
}

- (void)_presentWithContentViewController:(UIViewController*)contentViewController
                       fromViewController:(UIViewController*)sourceViewController
                                    modal:(BOOL)modal
                                 animated:(BOOL)animated
                               completion:(void(^)(void))completion
{
    NSParameterAssert(contentViewController);
    NSParameterAssert(sourceViewController);
    
    // we present without animation only when we replace already presented controller
    BOOL shouldReplaceContent = self.presented;
    
    // set touches passthrough
    [self.class popinWindow].passthroughTouches = !modal;
    
    // remove gestures
    [self _removeDismissOnBackdropTap];
    [self _removeDismissOnScrollHandler];
    
    // assign popinController to content controller
    contentViewController.popinController = self;
    
    void(^alongsideAnimation)(void) = ^{
        // backdrop will be animated alongside
        // and animated individually when replacing controller
        [self.containerController setShowsBackdrop:modal animated:shouldReplaceContent];
    };
    
    void(^animationFinished)(void) = ^{
        if(completion) {
            completion();
        }
        
        if(!self.presented) { // can be dismissed in between transition.
            return;
        }
        
        if(modal) {
            // add dismiss on tap handler when using modal presentation
            [self _addDismissOnBackdropTap];
        }
        else {
            // add dismiss on scroll handler when using non-modal presentation
            [self _addDismissOnScrollHandler:sourceViewController];
        }
    };
    
    // Replace content view controller if controller is already presented
    if(shouldReplaceContent)
    {
        self.contentViewController.popinController = nil;
        
        self.contentViewController = contentViewController;
        self.sourceViewController = sourceViewController;
        
        [self.containerController setContentViewController:contentViewController
                                                  animated:NO
                                        alongsideAnimation:alongsideAnimation
                                                completion:animationFinished];
        
        if(completion) {
            completion();
        }
    }
    else
    {
        self.presented = YES;
        
        self.contentViewController = contentViewController;
        self.sourceViewController = sourceViewController;
        
        self.containerController = [[PBPopinContainerViewController alloc] initWithContentViewController:nil];
        [self.class popinWindow].rootViewController = self.containerController;
        [self _showPopinWindow];
        
        [self _sendControllerWillAppearNotication:animated];
        
        __weak typeof(self) weakSelf = self;
        
        [self.containerController setContentViewController:self.contentViewController
                                                  animated:animated
                                        alongsideAnimation:alongsideAnimation
                                                completion:^{
                                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                                    
                                                    // check if still presented
                                                    if(strongSelf.presented) {
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:PBPopinControllerDidAppearNotification object:nil];
                                                    }
                                                    
                                                    animationFinished();
                                                }];
    }
}

#pragma mark - Notifications

- (NSDictionary *)_transitionInfoForUserInfoDictionary:(BOOL)isAnimatedTransition {
    NSMutableDictionary *transitionInfo = [NSMutableDictionary new];
    
    transitionInfo[PBPopinControllerAnimationDurationUserInfoKey] = @(isAnimatedTransition ? [self.containerController transitionDuration] : 0);
    transitionInfo[PBPopinControllerAnimationCurveUserInfoKey] = @(isAnimatedTransition ? [self.containerController transitionAnimationCurve] : 0);
    
    return transitionInfo;
}

- (void)_sendControllerWillAppearNotication:(BOOL)isAnimated {
    CGRect initialFrame = [self.containerController initialFrameForTransitionView:self.contentViewController];
    CGRect finalFrame = [self.containerController finalFrameForTransitionView:self.contentViewController];
    
    NSDictionary *transitionInfo = [self _transitionInfoForUserInfoDictionary:isAnimated];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:transitionInfo];
    userInfo[PBPopinControllerInitialFrameUserInfoKey] = [NSValue valueWithCGRect:initialFrame];
    userInfo[PBPopinControllerFinalFrameUserInfoKey] = [NSValue valueWithCGRect:finalFrame];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPopinControllerWillAppearNotification object:nil userInfo:userInfo];
}

- (void)_sendControllerWillDisappearNotification:(BOOL)isAnimated {
    CGRect initialFrame = [self.containerController finalFrameForTransitionView:self.contentViewController];
    CGRect finalFrame = [self.containerController initialFrameForTransitionView:self.contentViewController];
    
    NSDictionary *transitionInfo = [self _transitionInfoForUserInfoDictionary:isAnimated];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:transitionInfo];
    userInfo[PBPopinControllerInitialFrameUserInfoKey] = [NSValue valueWithCGRect:initialFrame];
    userInfo[PBPopinControllerFinalFrameUserInfoKey] = [NSValue valueWithCGRect:finalFrame];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPopinControllerWillDisappearNotification object:nil userInfo:userInfo];
}

#pragma mark - BackdropView: dismiss on tap

- (void)_addDismissOnBackdropTap {
    [self _removeDismissOnBackdropTap];
    self.dismissTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTapGesture:)];
    [self.containerController.backdropView addGestureRecognizer:self.dismissTapGestureRecognizer];
}

- (void)_removeDismissOnBackdropTap {
    [[self.dismissTapGestureRecognizer view] removeGestureRecognizer:self.dismissTapGestureRecognizer];
    self.dismissTapGestureRecognizer = nil;
}

- (void)_handleTapGesture:(UIGestureRecognizer *)gestureRecognizer {
    [self dismissAnimated:YES completion:nil];
}

#pragma mark - UIScrollView: dismiss on scroll

- (void)_addDismissOnScrollHandler:(UIViewController*)sourceViewController {
    [self _removeDismissOnScrollHandler];
    
    if([sourceViewController.view isKindOfClass:UIScrollView.class]) {
        UIScrollView* scrollView = (UIScrollView*)sourceViewController.view;
        [scrollView.panGestureRecognizer addTarget:self action:@selector(_handlePanGesture:)];
    }
}

- (void)_removeDismissOnScrollHandler {
    if([self.sourceViewController.view isKindOfClass:UIScrollView.class]) {
        UIScrollView* scrollView = (UIScrollView*)self.sourceViewController.view;
        [scrollView.panGestureRecognizer removeTarget:self action:@selector(_handlePanGesture:)];
    }
}

- (void)_handlePanGesture:(UIPanGestureRecognizer*)recognizer {
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        [self dismissAnimated:YES completion:nil];
    }
}

@end

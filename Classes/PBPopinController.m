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

@interface _PBPopinWindow : UIWindow
@end

@implementation _PBPopinWindow

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
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

- (instancetype)init {
    if(self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillAppear:(NSNotification*)notification {
    if(self.presented) {
        [self dismissAnimated:YES completion:nil];
    }
}

- (void)presentWithContentViewController:(UIViewController*)contentViewController
                      fromViewController:(UIViewController*)sourceViewController
                                animated:(BOOL)animated
                              completion:(void(^)(void))completion {
    [self presentWithContentViewController:contentViewController
                        fromViewController:sourceViewController
                                  fromView:nil
                                  animated:animated
                                completion:completion];
}

- (void)presentWithContentViewController:(UIViewController*)contentViewController
                      fromViewController:(UIViewController*)sourceViewController
                                fromView:(UIView *)fromView
                                animated:(BOOL)animated
                              completion:(void(^)(void))completion {
    NSParameterAssert(contentViewController);
    NSParameterAssert(sourceViewController);
    NSParameterAssert(!fromView || [fromView isKindOfClass:UIView.class]);
    
    // dismiss keyboard
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    // assign popinController to content controller
    contentViewController.popinController = self;
    
    // Replace content view controller if controller is already presented
    if(self.presented)
    {
        self.contentViewController.popinController = nil;
        
        self.contentViewController = contentViewController;
        self.sourceViewController = sourceViewController;
        self.sourceView = fromView;
        
        __weak typeof(self) weakSelf = self;
        
        [self.containerController setContentViewController:contentViewController
                                                  animated:NO
                                        alongsideAnimation:^{
                                            __strong typeof(weakSelf) strongSelf = weakSelf;
                                            
                                            // adjust scroll view insets
                                            [strongSelf _adjustScrollViewContentInsets:YES
                                                                  sourceViewController:sourceViewController
                                                                 contentViewController:contentViewController];
                                            
                                            // adjust scroll view content offset
                                            [strongSelf _adjustScrollViewContentOffset:sourceViewController
                                                                 contentViewController:contentViewController
                                                                              fromView:fromView];
                                        }
                                                completion:nil];
        
        if(completion) {
            completion();
        }
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:PBPopinControllerWillAppearNotification object:self];
        
        self.presented = YES;
        
        self.contentViewController = contentViewController;
        self.sourceViewController = sourceViewController;
        self.sourceView = fromView;
        
        self.containerController = [[PBPopinContainerViewController alloc] initWithContentViewController:nil];
        [self.class popinWindow].rootViewController = self.containerController;
        [self _showPopinWindow];
        
        __weak typeof(self) weakSelf = self;
        
        [self.containerController setContentViewController:self.contentViewController
                                                  animated:animated
                                        alongsideAnimation:^{
                                            __strong typeof(weakSelf) strongSelf = weakSelf;
                                            
                                            // adjust scroll view insets
                                            [strongSelf _adjustScrollViewContentInsets:YES
                                                                  sourceViewController:sourceViewController
                                                                 contentViewController:contentViewController];
                                            
                                            // adjust scroll view content offset
                                            [strongSelf _adjustScrollViewContentOffset:sourceViewController
                                                                 contentViewController:contentViewController
                                                                              fromView:fromView];
                                        }
                                                completion:^{
                                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                                    
                                                    // check if still presented
                                                    if(strongSelf.presented) {
                                                        // add dismiss on scroll handler
                                                        [strongSelf _addDismissOnScrollHandler:sourceViewController];
                                                        
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:PBPopinControllerDidAppearNotification object:strongSelf];
                                                    }
                                                    
                                                    if(completion) {
                                                        completion();
                                                    }
                                                }];
    }
}

- (void)dismissAnimated:(BOOL)animated completion:(void(^)(void))completion {
    NSAssert(self.presented, @"Unbalanced call to dismiss PopinController.");
    
    __weak typeof(self) weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPopinControllerWillDisappearNotification object:self];
    
    self.presented = NO;
    [self _removeDismissOnScrollHandler];
    
    [self.containerController setContentViewController:nil
                                              animated:animated
                                    alongsideAnimation:^{
                                        __strong typeof(weakSelf) strongSelf = weakSelf;
                                        
                                        // adjust scroll view insets
                                        [strongSelf _adjustScrollViewContentInsets:NO
                                                              sourceViewController:strongSelf.sourceViewController
                                                             contentViewController:strongSelf.contentViewController];
                                    }
                                            completion:^{
                                                __strong typeof(weakSelf) strongSelf = weakSelf;
                                                
                                                // check if still dismissed
                                                if(!strongSelf.presented) {
                                                    [strongSelf.class popinWindow].rootViewController = nil;
                                                    strongSelf.containerController = nil;
                                                    strongSelf.sourceView = nil;
                                                    strongSelf.contentViewController.popinController = nil;
                                                    
                                                    [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
                                                    [strongSelf _hidePopinWindow];
                                                    
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:PBPopinControllerDidDisappearNotification object:strongSelf];
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

#pragma mark - UIScrollView: adjust content insets

- (void)_adjustScrollViewContentOffset:(UIViewController *)sourceViewController
                 contentViewController:(UIViewController *)contentViewController
                              fromView:(UIView *)fromView
{
    if(![sourceViewController.view isKindOfClass:UIScrollView.class]) {
        return;
    }
    
    UIScrollView *scrollView = (UIScrollView *)sourceViewController.view;
    CGRect transitionViewRect = [self.containerController finalFrameForTransitionView:contentViewController];
    CGRect fromViewRect = [fromView convertRect:fromView.bounds toView:nil];
    
    if(CGRectIntersectsRect(fromViewRect, transitionViewRect)) {
        CGPoint scrollOffset = scrollView.contentOffset;
        scrollOffset.y += CGRectGetMaxY(fromViewRect) - CGRectGetMinY(transitionViewRect);
        [scrollView setContentOffset:scrollOffset animated:NO];
    }
}

- (void)_adjustScrollViewContentInsets:(BOOL)presenting
                  sourceViewController:(UIViewController *)sourceViewController
                 contentViewController:(UIViewController *)contentViewController
{
    if(![sourceViewController.view isKindOfClass:UIScrollView.class]) {
        return;
    }
    
    UIEdgeInsets popinContentInsets = self.scrollViewContentInsets;
    UIScrollView *scrollView = (UIScrollView *)sourceViewController.view;
    UIEdgeInsets scrollContentInset = scrollView.contentInset;
    
    if(presenting) {
        CGRect transitionViewRect = [self.containerController finalFrameForTransitionView:contentViewController];
        
        // substract previous inset
        scrollContentInset.bottom -= popinContentInsets.bottom;
        
        // calculate new inset
        popinContentInsets.bottom = CGRectGetHeight(transitionViewRect);
        
        // add new inset
        scrollContentInset.bottom += popinContentInsets.bottom;
        
        // save new insets
        self.scrollViewContentInsets = popinContentInsets;
    }
    else {
        // substract previous inset
        scrollContentInset.bottom -= popinContentInsets.bottom;
        
        // reset saved inset
        popinContentInsets.bottom = 0;
        
        // save new insets
        self.scrollViewContentInsets = popinContentInsets;
    }
    
    scrollView.contentInset = scrollContentInset;
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

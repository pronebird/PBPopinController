//
//  PBPopinContainerViewController.m
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "PBPopinContainerViewController.h"

#define UIViewAnimationOptionCurveKeyboard 7 << 16

@interface PBPopinContainerViewController ()

@property (readwrite) UIViewController* contentViewController;

@end

@implementation PBPopinContainerViewController

- (instancetype)initWithContentViewController:(UIViewController*)contentViewController {
    if(self = [super init]) {
        self.contentViewController = contentViewController;
    }
    return self;
}

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated completion:(void(^)(void))completion {
    UIViewController* currentContentController = self.contentViewController;
    
    // set content controller to nil to dismiss presented one
    if(!contentViewController)
    {
        self.contentViewController = nil;
        
        [self _dismissContentViewController:currentContentController animated:animated completion:^{
            [self _removeContentViewController:currentContentController];
            
            if(completion) {
                completion();
            }
        }];
    }
    else if(!currentContentController) // if there is currently no controller presented
    {
        self.contentViewController = contentViewController;
        [self _addContentViewController:contentViewController];
        [self _presentContentViewController:contentViewController animated:animated completion:completion];
    }
    else // replace current controller
    {
        self.contentViewController = contentViewController;
        [self _removeContentViewController:currentContentController];
        [self _addContentViewController:contentViewController];
        
        if(completion) {
            completion();
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.contentViewController && self.contentViewController.parentViewController != self) {
        [self _addContentViewController:self.contentViewController];
    }
}

#pragma mark - Content size changes

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.contentViewController.view.frame = [self _frameForContentController:self.contentViewController];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {}];
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container {
    self.contentViewController.view.frame = [self _frameForContentController:self.contentViewController];
}

#pragma mark - Presentation animations

- (CGRect)_frameForContentController:(UIViewController*)controller {
    CGSize preferredSize = [controller preferredContentSize];
    if(CGSizeEqualToSize(preferredSize, CGSizeZero)) {
        preferredSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) * 0.5);
    }
    
    return CGRectMake(0, CGRectGetHeight(self.view.bounds) - preferredSize.height, preferredSize.width, preferredSize.height);
}

- (CGRect)_initialFrameForContentController:(UIViewController*)controller {
    CGRect rect = [self _frameForContentController:controller];
    
    rect.origin.y = CGRectGetHeight(self.view.bounds);
    
    return rect;
}

- (NSTimeInterval)_transitionDuration {
    return 0.4;
}

- (UIViewAnimationOptions)_animationOptions {
    return UIViewAnimationOptionCurveKeyboard | UIViewAnimationOptionBeginFromCurrentState;
}

- (void)_presentContentViewController:(UIViewController*)controller animated:(BOOL)animated completion:(void(^)(void))completion {
    void(^animations)(void) = ^{
        controller.view.frame = [self _frameForContentController:controller];
    };
    
    void(^animationCompletion)(BOOL finished) = ^(BOOL finished) {
        if(completion) {
            completion();
        }
    };

    controller.view.frame = [self _initialFrameForContentController:controller];
    
    if(animated) {
        [UIView animateWithDuration:[self _transitionDuration]
                              delay:0.0
                            options:[self _animationOptions]
                         animations:animations
                         completion:animationCompletion];
    } else {
        [UIView performWithoutAnimation:animations];
        animationCompletion(YES);
    }
}

- (void)_dismissContentViewController:(UIViewController*)controller animated:(BOOL)animated completion:(void(^)(void))completion {
    void(^animations)(void) = ^{
        controller.view.frame = [self _initialFrameForContentController:controller];
    };
    
    void(^animationCompletion)(BOOL finished) = ^(BOOL finished) {
        if(completion) {
            completion();
        }
    };
    
    if(animated) {
        [UIView animateWithDuration:[self _transitionDuration]
                              delay:0.0
                            options:[self _animationOptions]
                         animations:animations
                         completion:animationCompletion];
    } else {
        [UIView performWithoutAnimation:animations];
        animationCompletion(YES);
    }
}

#pragma mark - Private

- (void)_addContentViewController:(UIViewController*)controller {
    [self addChildViewController:controller];
    
    controller.view.frame = [self _frameForContentController:controller];
    [self.view addSubview:controller.view];
    
    [controller didMoveToParentViewController:self];
}

- (void)_removeContentViewController:(UIViewController*)controller {
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
}

@end

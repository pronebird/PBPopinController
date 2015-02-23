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
    if(!contentViewController)
    {
        [self _animateDismissal:animated completion:^{
            [self _removeContentViewController];
            self.contentViewController = nil;
            
            if(completion) {
                completion();
            }
        }];
    }
    else if(!self.contentViewController)
    {
        self.contentViewController = contentViewController;
        [self _addContentViewController];
        
        [self _animatePresentation:animated completion:completion];
    }
    else
    {
        [self _removeContentViewController];
        
        self.contentViewController = contentViewController;
        [self _addContentViewController];
        
        if(completion) {
            completion();
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.contentViewController && self.contentViewController.parentViewController != self) {
        [self _addContentViewController];
    }
}

#pragma mark - Presentation animations

- (CGRect)_frameForContentController {
    CGSize preferredSize = [self.contentViewController preferredContentSize];
    if(CGSizeEqualToSize(preferredSize, CGSizeZero)) {
        preferredSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) * 0.5);
    }
    
    return CGRectMake(0, CGRectGetHeight(self.view.bounds) - preferredSize.height, preferredSize.width, preferredSize.height);
}

- (CGRect)_initialFrameForContentController {
    CGRect rect = [self _frameForContentController];
    
    rect.origin.y = CGRectGetHeight(self.view.bounds);
    
    return rect;
}

- (NSTimeInterval)_transitionDuration {
    return 0.4;
}

- (void)_animatePresentation:(BOOL)animated completion:(void(^)(void))completion {
    void(^animations)(void) = ^{
        self.contentViewController.view.frame = [self _frameForContentController];
    };
    void(^animationCompletion)(BOOL finished) = ^(BOOL finished) {
        if(completion) {
            completion();
        }
    };

    self.contentViewController.view.frame = [self _initialFrameForContentController];
    
    if(animated) {
        [UIView animateWithDuration:[self _transitionDuration]
                              delay:0.0
                            options:UIViewAnimationOptionCurveKeyboard
                         animations:animations
                         completion:animationCompletion];
    } else {
        [UIView performWithoutAnimation:animations];
        animationCompletion(YES);
    }
}

- (void)_animateDismissal:(BOOL)animated completion:(void(^)(void))completion {
    void(^animations)(void) = ^{
        self.contentViewController.view.frame = [self _initialFrameForContentController];
    };
    void(^animationCompletion)(BOOL finished) = ^(BOOL finished) {
        if(completion) {
            completion();
        }
    };
    
    if(animated) {
        [UIView animateWithDuration:[self _transitionDuration]
                              delay:0.0
                            options:UIViewAnimationOptionCurveKeyboard
                         animations:animations
                         completion:animationCompletion];
    } else {
        [UIView performWithoutAnimation:animations];
        animationCompletion(YES);
    }
}

#pragma mark - Private

- (void)_addContentViewController {
    [self addChildViewController:self.contentViewController];
    
    self.contentViewController.view.frame = [self _frameForContentController];
    [self.view addSubview:self.contentViewController.view];
    
    [self.contentViewController didMoveToParentViewController:self];
}

- (void)_removeContentViewController {
    [self.contentViewController willMoveToParentViewController:nil];
    [self.contentViewController.view removeFromSuperview];
    [self.contentViewController removeFromParentViewController];
}

@end

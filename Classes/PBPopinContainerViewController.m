//
//  PBPopinContainerViewController.m
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "PBPopinContainerViewController.h"
#import "UIViewController+PopinController.h"

#define UIViewAnimationOptionCurveKeyboard 7 << 16

// Marker classes for debugging purposes
@interface _PBPopinTransitionView : UIView @end
@implementation _PBPopinTransitionView @end
@interface _PBPopinContainerView : UIView @end
@implementation _PBPopinContainerView @end

@interface PBPopinContainerViewController ()

/**
 *  Current content controller.
 */
@property (readwrite) UIViewController* contentViewController;

/**
 *  This view is used for animations and contains accessory view and content view.
 */
@property UIView* transitionView;

@end

@implementation PBPopinContainerViewController

- (void)loadView {
    self.view = [[_PBPopinContainerView alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithContentViewController:(UIViewController*)contentViewController {
    if(self = [super init]) {
        self.contentViewController = contentViewController;
    }
    return self;
}

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated completion:(void(^)(void))completion {
    UIViewController* presentedContentController = self.contentViewController;
    UIView* transitionView = self.transitionView;
    
    // check if equal
    if(contentViewController == presentedContentController) {
        if(completion) {
            completion();
        }
        return;
    }
    
    // set content controller to nil to dismiss presented one
    if(!contentViewController)
    {
        NSParameterAssert(transitionView);
        
        self.contentViewController = nil;
        self.transitionView = nil;
        
        [self _dismissContentViewController:presentedContentController
                             transitionView:transitionView
                                   animated:animated
                                 completion:^{
                                     // remove content view controller
                                     [self _removeContentViewController:presentedContentController
                                                     fromTransitionView:transitionView];
                                     
                                     // remove transition view
                                     [transitionView removeFromSuperview];
                                     
                                     if(completion) {
                                         completion();
                                     }
                                 }];
    }
    else if(!presentedContentController) // if there is currently no controller presented
    {
        NSParameterAssert(transitionView == nil);
        
        self.contentViewController = contentViewController;
        self.transitionView = [self _createTransitionView];
        
        [self _addContentViewController:contentViewController intoTransitionView:self.transitionView];
        [self _presentContentViewController:contentViewController
                             transitionView:self.transitionView
                                   animated:animated
                                 completion:completion];
    }
    else // replace current controller
    {
        NSParameterAssert(transitionView);
        
        self.contentViewController = contentViewController;
        
        [self _removeContentViewController:presentedContentController fromTransitionView:transitionView];
        [self _addContentViewController:contentViewController intoTransitionView:transitionView];
        
        if(completion) {
            completion();
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // add content controller if not in hierarchy yet
    if(self.contentViewController && self.contentViewController.parentViewController != self) {
        self.transitionView = [self _createTransitionView];
        
        [self _addContentViewController:self.contentViewController intoTransitionView:self.transitionView];
    }
}

#pragma mark - Content size changes

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self _layoutTransitionView:self.transitionView controller:self.contentViewController];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {}];
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container {
    [self _layoutTransitionView:self.transitionView controller:self.contentViewController];
}

#pragma mark - Presentation animations

- (CGRect)_finalFrameForTransitionView:(UIViewController*)controller {
    CGRect transitionRect;
    UIView* accessoryView = controller.popinAccessoryView;
    
    transitionRect.size = [self _sizeForContentController:controller];
    transitionRect.origin.x = 0;
    transitionRect.origin.y = CGRectGetHeight(self.view.bounds) - transitionRect.size.height;
    
    if(accessoryView) {
        CGSize accessorySize = [self _sizeForAccessoryView:accessoryView];
        
        transitionRect.origin.y -= accessorySize.height;
        transitionRect.size.height += accessorySize.height;
    }

    return transitionRect;
}

- (CGRect)_initialFrameForTransitionView:(UIViewController*)controller {
    CGRect transitionRect = [self _finalFrameForTransitionView:controller];
    
    transitionRect.origin.y = CGRectGetHeight(self.view.bounds);
    
    return transitionRect;
}

- (NSTimeInterval)_transitionDuration {
    return 0.4;
}

- (UIViewAnimationOptions)_animationOptions {
    return UIViewAnimationOptionCurveKeyboard | UIViewAnimationOptionBeginFromCurrentState;
}

- (void)_presentContentViewController:(UIViewController*)controller
                       transitionView:(UIView*)transitionView
                             animated:(BOOL)animated
                           completion:(void(^)(void))completion
{
    NSParameterAssert(transitionView);
    
    void(^animations)(void) = ^{
        transitionView.frame = [self _finalFrameForTransitionView:controller];
    };
    
    void(^animationCompletion)(BOOL finished) = ^(BOOL finished) {
        if(completion) {
            completion();
        }
    };

    transitionView.frame = [self _initialFrameForTransitionView:controller];
    
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

- (void)_dismissContentViewController:(UIViewController*)controller
                       transitionView:(UIView*)transitionView
                             animated:(BOOL)animated
                           completion:(void(^)(void))completion
{
    void(^animations)(void) = ^{
       transitionView.frame = [self _initialFrameForTransitionView:controller];
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

- (UIView*)_createTransitionView {
    UIView* transitionView = [[_PBPopinTransitionView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:transitionView];
    
    return transitionView;
}

- (CGSize)_sizeForAccessoryView:(UIView*)accessoryView {
    CGSize size = accessoryView.intrinsicContentSize;
    
    size.width = CGRectGetWidth(self.view.bounds);
    
    return size;
}

- (CGSize)_sizeForContentController:(UIViewController*)controller {
    CGSize preferredSize = [controller preferredContentSize];
    
    if(CGSizeEqualToSize(preferredSize, CGSizeZero)) {
        preferredSize = CGSizeMake(0, CGRectGetHeight(self.view.bounds) * 0.5);
    }
    
    preferredSize.width = CGRectGetWidth(self.view.bounds);
    
    return preferredSize;
}

- (void)_layoutTransitionView:(UIView*)transitionView controller:(UIViewController*)controller {
    UIView* accessoryView = controller.popinAccessoryView;
    
    CGSize accessorySize = [self _sizeForAccessoryView:accessoryView];
    CGSize contentSize = [self _sizeForContentController:controller];
    CGRect accessoryRect;
    CGRect contentRect;
    
    accessoryRect.origin = CGPointZero;
    accessoryRect.size = accessorySize;

    contentRect.origin = CGPointMake(0, accessorySize.height);
    contentRect.size = contentSize;
    
    transitionView.frame = [self _finalFrameForTransitionView:controller];
    
    controller.view.frame = contentRect;
    accessoryView.frame = accessoryRect;
}

- (void)_addContentViewController:(UIViewController*)controller intoTransitionView:(UIView*)transitionView {
    UIView* accessoryView = controller.popinAccessoryView;
    
    // sharing the same accessory between popin controllers is ok,
    // but keyboard will throw an exception or mess view hierarchy.
    if(accessoryView.superview && ![accessoryView.superview isKindOfClass:_PBPopinTransitionView.class]) {
        [NSException raise:@"PBPopinContainerViewControllerHierarchyInconsistencyException"
                    format:@"Popin accessory view must not be in view hierarchy. Please create an individual instance of accessory view."];
    }

    [self addChildViewController:controller];
    [transitionView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    
    if(accessoryView) {
        // remove all constraints
        if(accessoryView.constraints.count) {
            [accessoryView removeConstraints:accessoryView.constraints];
        }
        
        accessoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        accessoryView.translatesAutoresizingMaskIntoConstraints = YES;
        
        [transitionView addSubview:accessoryView];
    }
    
    [self _layoutTransitionView:transitionView controller:controller];
}

- (void)_removeContentViewController:(UIViewController*)controller fromTransitionView:(UIView*)transitionView {
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
    
    // Edge case: same accessory can be reused
    // Make sure we remove it from current transition view only
    UIView* accessoryView = controller.popinAccessoryView;
    if(accessoryView.superview == transitionView) {
        [accessoryView removeFromSuperview];
    }
}

@end

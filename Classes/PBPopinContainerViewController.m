//
//  PBPopinContainerViewController.m
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "PBPopinContainerViewController.h"
#import "UIViewController+PopinController.h"

#define UIViewAnimationCurveKeyboard 7

#define MARKER_CLASS(__class, __super) \
    @interface __class : __super @end \
    @implementation __class @end

// Marker classes for debugging purposes
MARKER_CLASS(_PBPopinBackdropView, UIView)
MARKER_CLASS(_PBPopinTransitionView, UIView)
MARKER_CLASS(_PBPopinContainerView, UIView)

@interface PBPopinContainerViewController ()

/**
 *  Current content controller.
 */
@property (readwrite) UIViewController *contentViewController;

/**
 *  This view is used for animations and contains accessory view and content view.
 */
@property UIView *transitionView;

/**
 *  Backdrop view.
 */
@property (readwrite) UIView *backdropView;

@end

@implementation PBPopinContainerViewController

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.contentViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.contentViewController;
}

- (void)loadView {
    self.view = [[_PBPopinContainerView alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithContentViewController:(UIViewController*)contentViewController {
    if(self = [super init]) {
        self.contentViewController = contentViewController;
    }
    return self;
}

- (void)setShowsBackdrop:(BOOL)showsBackdrop {
    UIColor *backgroundColor;
    
    if(showsBackdrop) {
        backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    else {
        backgroundColor = [UIColor clearColor];
    }
    
    self.backdropView.backgroundColor = backgroundColor;
}

- (void)setShowsBackdrop:(BOOL)showsBackdrop animated:(BOOL)animated {
    void(^animationBlock)(void) = ^{
        [self setShowsBackdrop:showsBackdrop];
    };
    
    if(animated) {
        [UIView animateWithDuration:[self transitionDuration] delay:0.0 options:[self _animationOptions] animations:^{
            [self setShowsBackdrop:showsBackdrop];
        } completion:^(BOOL finished) {}];
    }
    else {
        animationBlock();
    }
}

- (void)setContentViewController:(UIViewController *)contentViewController
                        animated:(BOOL)animated
              alongsideAnimation:(void(^)(void))alongsideAnimation
                      completion:(void(^)(void))completion
{
    UIViewController* presentedContentController = self.contentViewController;
    
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
        self.contentViewController = nil;
        
        [self _dismissContentViewController:presentedContentController animated:animated alongsideAnimation:alongsideAnimation completion:^(BOOL finished) {
            if(!finished) {
                return;
            }
            
            // remove content view controller
            [self _removeContentViewController:presentedContentController];
            
            if(completion) {
                completion();
            }
        }];
    }
    else if(!presentedContentController) // if there is currently no controller presented
    {
        self.contentViewController = contentViewController;
        
        [self _addContentViewController:contentViewController animated:NO];
        [self _presentContentViewController:contentViewController animated:animated alongsideAnimation:alongsideAnimation completion:^(BOOL finished) {
            if(!finished) {
                return;
            }
            
            if(completion) {
                completion();
            }
        }];
    }
    else // replace current controller
    {
        self.contentViewController = contentViewController;
        
        [self _removeContentViewController:presentedContentController];
        [self _addContentViewController:contentViewController animated:YES];
        
        if(alongsideAnimation) {
            alongsideAnimation();
        }
        
        if(completion) {
            completion();
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup backdrop view
    self.backdropView = [[_PBPopinBackdropView alloc] initWithFrame:self.view.bounds];
    self.backdropView.translatesAutoresizingMaskIntoConstraints = NO;
    self.backdropView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.backdropView];
    
    NSDictionary *viewsDictionary = @{ @"backdrop": self.backdropView };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[backdrop]|" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backdrop]|" options:0 metrics:nil views:viewsDictionary]];
    
    // create transition view
    self.transitionView = [[_PBPopinTransitionView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.transitionView];
    
    // add content controller if not in hierarchy yet
    if(self.contentViewController && self.contentViewController.parentViewController != self) {
        [self _addContentViewController:self.contentViewController animated:NO];
    }
}

#pragma mark - Content size changes

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self _layoutTransitionViewAnimated:NO];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {}];
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container {
    [super preferredContentSizeDidChangeForChildContentContainer:container];
    
    [self _layoutTransitionViewAnimated:NO];
}

#pragma mark - Presentation animations

- (CGRect)finalFrameForTransitionView:(UIViewController*)controller {
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

- (CGRect)initialFrameForTransitionView:(UIViewController*)controller {
    CGRect transitionRect = [self finalFrameForTransitionView:controller];
    
    transitionRect.origin.y = CGRectGetHeight(self.view.bounds);
    
    return transitionRect;
}

- (NSTimeInterval)transitionDuration {
    return 0.25;
}

- (UIViewAnimationCurve)transitionAnimationCurve {
    return UIViewAnimationCurveKeyboard;
}

- (UIViewAnimationOptions)_animationOptions {
    return ([self transitionAnimationCurve] << 16) | UIViewAnimationOptionBeginFromCurrentState;
}

- (void)_presentContentViewController:(UIViewController *)controller
                             animated:(BOOL)animated
                   alongsideAnimation:(void(^)(void))alongsideAnimation
                           completion:(void(^)(BOOL finished))completion
{
    CGRect finalFrameForTransitionView = [self finalFrameForTransitionView:controller];
    void(^animations)(void) = ^{
        self.transitionView.frame = finalFrameForTransitionView;
        
        if(alongsideAnimation) {
            alongsideAnimation();
        }
    };
    
    void(^animationCompletion)(BOOL finished) = ^(BOOL finished) {
        if(completion) {
            completion(finished);
        }
    };

    self.transitionView.frame = [self initialFrameForTransitionView:controller];
    
    if(animated) {
        [UIView animateWithDuration:[self transitionDuration]
                              delay:0.0
                            options:[self _animationOptions]
                         animations:animations
                         completion:animationCompletion];
    } else {
        animations();
        animationCompletion(YES);
    }
}

- (void)_dismissContentViewController:(UIViewController *)controller
                             animated:(BOOL)animated
                   alongsideAnimation:(void(^)(void))alongsideAnimation
                           completion:(void(^)(BOOL finished))completion
{
    CGRect initialFrameForTransitionView = [self initialFrameForTransitionView:controller];
    void(^animations)(void) = ^{
       self.transitionView.frame = initialFrameForTransitionView;
        
        if(alongsideAnimation) {
            alongsideAnimation();
        }
    };
    
    void(^animationCompletion)(BOOL finished) = ^(BOOL finished) {
        if(completion) {
            completion(finished);
        }
    };
    
    if(animated) {
        [UIView animateWithDuration:[self transitionDuration]
                              delay:0.0
                            options:[self _animationOptions]
                         animations:animations
                         completion:animationCompletion];
    } else {
        animations();
        animationCompletion(YES);
    }
}

#pragma mark - Private

/**
 *  @abstract Calculate size for accessory view.
 *  @discussion This method uses intrinsicContentSize to determine desired size for accessory view.
 *  @internal
 *
 *  @param accessoryView an instance of accessory view
 *
 *  @return accessory view size or CGSizeZero
 */
- (CGSize)_sizeForAccessoryView:(UIView *)accessoryView {
    CGSize size = accessoryView.intrinsicContentSize;
    
    size.width = CGRectGetWidth(self.view.bounds);
    
    return size;
}

/**
 *  @abstract Calculate size for content controller view.
 *  @discussion This method uses preferredContentSize to determine desired size for content controller.
 *  @internal
 *
 *  @param controller a content controller
 *
 *  @return content controller size
 */
- (CGSize)_sizeForContentController:(UIViewController *)controller {
    // force viewDidLoad because sometimes preferredContentSize is calculated
    // based on intrinsic content size of elements inside of view
    [controller view];
    
    CGSize preferredSize = [controller preferredContentSize];
    
    if(CGSizeEqualToSize(preferredSize, CGSizeZero)) {
        preferredSize = CGSizeMake(0, CGRectGetHeight(self.view.bounds) * 0.5);
    }
    
    preferredSize.width = CGRectGetWidth(self.view.bounds);
    
    return preferredSize;
}

/**
 *  Layout accessory and content views in transition view.
 *  @internal
 *
 *  @param transitionView an instance of transitionView
 *  @param controller     an associated content controller
 *  @param animated       animate frame changes?
 */
- (void)_layoutTransitionViewAnimated:(BOOL)animated {
    UIView *accessoryView = self.contentViewController.popinAccessoryView;
    
    CGSize accessorySize = [self _sizeForAccessoryView:accessoryView];
    CGSize contentSize = [self _sizeForContentController:self.contentViewController];
    CGRect accessoryRect;
    CGRect contentRect;
    
    accessoryRect.origin = CGPointZero;
    accessoryRect.size = accessorySize;

    contentRect.origin = CGPointMake(0, accessorySize.height);
    contentRect.size = contentSize;
    
    CGRect transitionRect = [self finalFrameForTransitionView:self.contentViewController];
    
    if(animated) {
        [UIView animateWithDuration:[self transitionDuration]
                              delay:0.0
                            options:[self _animationOptions]
                         animations:^{
                             self.transitionView.frame = transitionRect;
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    else {
        self.transitionView.frame = transitionRect;
    }
    
    self.contentViewController.view.frame = contentRect;
    accessoryView.frame = accessoryRect;
}

/**
 *  Add content view controller into view hierarchy.
 *  @internal
 *
 *  @param controller     an instance of content view controller
 *  @param transitionView an instance of transition view
 *  @param animated       perform animated transition?
 */
- (void)_addContentViewController:(UIViewController *)controller animated:(BOOL)animated {
    UIView* accessoryView = controller.popinAccessoryView;
    
    // sharing the same accessory between popin controllers is ok,
    // but keyboard will throw an exception or mess view hierarchy.
    if(accessoryView.superview && ![accessoryView.superview isKindOfClass:_PBPopinTransitionView.class]) {
        [NSException raise:@"PBPopinContainerViewControllerHierarchyInconsistencyException"
                    format:@"Popin accessory view must not be in view hierarchy. Please create an individual instance of accessory view."];
    }

    [self addChildViewController:controller];
    [self.transitionView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    
    if(accessoryView) {
        // remove all constraints
        if(accessoryView.constraints.count) {
            [accessoryView removeConstraints:accessoryView.constraints];
        }
        
        accessoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        accessoryView.translatesAutoresizingMaskIntoConstraints = YES;
        
        [self.transitionView addSubview:accessoryView];
    }
    
    [self _layoutTransitionViewAnimated:animated];
    
    // update statusbar appearance after adding new content controller
    [self setNeedsStatusBarAppearanceUpdate];
}

/**
 *  Remove content view controller from view hierarchy.
 *  @internal
 *
 *  @param controller     an instance of content view controller
 *  @param transitionView an instance of transition view
 */
- (void)_removeContentViewController:(UIViewController *)controller {
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
    
    // Edge case: same accessory can be reused so make sure we remove it from our own views only
    UIView *accessoryView = controller.popinAccessoryView;
    if(accessoryView.superview == self.transitionView) {
        [accessoryView removeFromSuperview];
    }
}

@end

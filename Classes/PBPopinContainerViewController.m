//
//  PBPopinContainerViewController.m
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "PBPopinContainerViewController.h"
#import "UIViewController+PopinController.h"

#define UIViewAnimationOptionCurveKeyboard 7 << 16

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
@property (readwrite) UIViewController* contentViewController;

/**
 *  This view is used for animations and contains accessory view and content view.
 */
@property UIView* transitionView;

/**
 *  Backdrop view.
 */
@property (readwrite) UIView *backdropView;

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
        [UIView animateWithDuration:[self _transitionDuration]
                              delay:0.0
                            options:[self _animationOptions]
                         animations:^{
                             [self setShowsBackdrop:showsBackdrop];
                         }
                         completion:^(BOOL finished) {}];
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
                         alongsideAnimation:alongsideAnimation
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
        
        [self _addContentViewController:contentViewController intoTransitionView:self.transitionView animated:NO];
        [self _presentContentViewController:contentViewController
                             transitionView:self.transitionView
                                   animated:animated
                         alongsideAnimation:alongsideAnimation
                                 completion:completion];
    }
    else // replace current controller
    {
        NSParameterAssert(transitionView);
        
        self.contentViewController = contentViewController;
        
        [self _removeContentViewController:presentedContentController fromTransitionView:transitionView];
        [self _addContentViewController:contentViewController intoTransitionView:transitionView animated:YES];
        
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
    
    // add content controller if not in hierarchy yet
    if(self.contentViewController && self.contentViewController.parentViewController != self) {
        self.transitionView = [self _createTransitionView];
        
        [self _addContentViewController:self.contentViewController intoTransitionView:self.transitionView animated:NO];
    }
    
    // setup backdrop view
    self.backdropView = [[_PBPopinBackdropView alloc] initWithFrame:self.view.bounds];
    self.backdropView.translatesAutoresizingMaskIntoConstraints = NO;
    self.backdropView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.backdropView];
    
    NSDictionary *viewsDictionary = @{ @"backdrop": self.backdropView };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[backdrop]|" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backdrop]|" options:0 metrics:nil views:viewsDictionary]];
}

#pragma mark - Content size changes

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self _layoutTransitionView:self.transitionView controller:self.contentViewController animated:NO];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {}];
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container {
    [super preferredContentSizeDidChangeForChildContentContainer:container];
    
    [self _layoutTransitionView:self.transitionView controller:self.contentViewController animated:NO];
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

- (CGRect)_initialFrameForTransitionView:(UIViewController*)controller {
    CGRect transitionRect = [self finalFrameForTransitionView:controller];
    
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
                   alongsideAnimation:(void(^)(void))alongsideAnimation
                           completion:(void(^)(void))completion
{
    NSParameterAssert(transitionView);
    
    CGRect finalFrameForTransitionView = [self finalFrameForTransitionView:controller];
    void(^animations)(void) = ^{
        transitionView.frame = finalFrameForTransitionView;
        
        if(alongsideAnimation) {
            alongsideAnimation();
        }
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
        animations();
        animationCompletion(YES);
    }
}

- (void)_dismissContentViewController:(UIViewController*)controller
                       transitionView:(UIView*)transitionView
                             animated:(BOOL)animated
                   alongsideAnimation:(void(^)(void))alongsideAnimation
                           completion:(void(^)(void))completion
{
    CGRect initialFrameForTransitionView = [self _initialFrameForTransitionView:controller];
    void(^animations)(void) = ^{
       transitionView.frame = initialFrameForTransitionView;
        
        if(alongsideAnimation) {
            alongsideAnimation();
        }
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
        animations();
        animationCompletion(YES);
    }
}

#pragma mark - Private

/**
 *  Create new transition view and add it to view hierarchy.
 *  @internal
 *
 *  @return an instance of _PBPopinTransitionView
 */
- (_PBPopinTransitionView *)_createTransitionView {
    _PBPopinTransitionView* transitionView = [[_PBPopinTransitionView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:transitionView];
    
    return transitionView;
}

/**
 *  @abstract Calculate size for accessory view.
 *  @discussion This method uses intrinsicContentSize to determine desired size for accessory view.
 *  @internal
 *
 *  @param accessoryView an instance of accessory view
 *
 *  @return accessory view size or CGSizeZero
 */
- (CGSize)_sizeForAccessoryView:(UIView*)accessoryView {
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
- (CGSize)_sizeForContentController:(UIViewController*)controller {
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
- (void)_layoutTransitionView:(UIView*)transitionView controller:(UIViewController*)controller animated:(BOOL)animated {
    UIView* accessoryView = controller.popinAccessoryView;
    
    CGSize accessorySize = [self _sizeForAccessoryView:accessoryView];
    CGSize contentSize = [self _sizeForContentController:controller];
    CGRect accessoryRect;
    CGRect contentRect;
    
    accessoryRect.origin = CGPointZero;
    accessoryRect.size = accessorySize;

    contentRect.origin = CGPointMake(0, accessorySize.height);
    contentRect.size = contentSize;
    
    CGRect transitionRect = [self finalFrameForTransitionView:controller];
    
    if(animated) {
        [UIView animateWithDuration:[self _transitionDuration]
                              delay:0.0
                            options:[self _animationOptions]
                         animations:^{
                             transitionView.frame = transitionRect;
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    else {
        transitionView.frame = transitionRect;
    }
    
    controller.view.frame = contentRect;
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
- (void)_addContentViewController:(UIViewController*)controller intoTransitionView:(UIView*)transitionView animated:(BOOL)animated {
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
    
    
    [self _layoutTransitionView:transitionView controller:controller animated:animated];
}

/**
 *  Remove content view controller from view hierarchy.
 *  @internal
 *
 *  @param controller     an instance of content view controller
 *  @param transitionView an instance of transition view
 */
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

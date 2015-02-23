//
//  PBPopinController.m
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "PBPopinController.h"
#import "PBPopinWindow.h"
#import "PBPopinContainerViewController.h"
#import "UIViewController+PopinController.h"

NSString* const PBPopinControllerWillAppearNotification = @"PopinControllerWillAppearNotification";
NSString* const PopinControllerDidAppearNotification = @"PopinControllerDidAppearNotification";
NSString* const PBPopinControllerWillDisappearNotification = @"PopinControllerWillDisappearNotification";
NSString* const PBPopinControllerDidDisappearNotification = @"PopinControllerDidDisappearNotification";

@interface UIViewController ()

@property (readwrite, nonatomic) PBPopinController* popinController;

@end

@interface PBPopinController()

@property PBPopinContainerViewController* containerController;
@property (weak, readwrite) UIViewController* sourceViewController;
@property (readwrite) UIViewController* contentViewController;
@property (readwrite) BOOL presented;

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

+ (PBPopinWindow*)popinWindow {
    static PBPopinWindow* popinWindow;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        popinWindow = [[PBPopinWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
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
    NSLog(@"%s", __PRETTY_FUNCTION__);

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
    NSParameterAssert(contentViewController);
    NSParameterAssert(sourceViewController);
    
    // dismiss keyboard
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    // assign popinController to content controller
    contentViewController.popinController = self;
    
    // add dismiss on scroll handler
    [self _addDismissOnScrollHandler:sourceViewController];
    
    // Replace content view controller if controller is already presented
    if(self.presented)
    {
        self.contentViewController.popinController = nil;
        
        self.contentViewController = contentViewController;
        self.sourceViewController = sourceViewController;
        
        [self.containerController setContentViewController:contentViewController animated:NO completion:nil];
        
        if(completion) {
            completion();
        }
    }
    else
    {
        self.contentViewController = contentViewController;
        self.sourceViewController = sourceViewController;
        
        self.containerController = [[PBPopinContainerViewController alloc] initWithContentViewController:nil];
        [self.class popinWindow].rootViewController = self.containerController;
        [self _showPopinWindow];
        
        __weak typeof(self) weakSelf = self;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PBPopinControllerWillAppearNotification object:self];
        
        [self.containerController setContentViewController:self.contentViewController animated:animated completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:PopinControllerDidAppearNotification object:weakSelf];
            
            if(completion) {
                completion();
            }
        }];
        
        self.presented = YES;
    }
}

- (void)dismissAnimated:(BOOL)animated completion:(void(^)(void))completion {
    NSAssert(self.presented, @"Unbalanced call to dismiss PopinController.");
    
    __weak typeof(self) weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPopinControllerWillDisappearNotification object:self];
    
    [self.containerController setContentViewController:nil animated:animated completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.class popinWindow].rootViewController = nil;
        strongSelf.containerController = nil;
        strongSelf.contentViewController.popinController = nil;
        
        [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
        [strongSelf _hidePopinWindow];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PBPopinControllerDidDisappearNotification object:strongSelf];
        
        if(completion) {
            completion();
        }
    }];
    
    [self _removeDismissOnScrollHandler];
    
    self.presented = NO;
}

#pragma mark - Private

- (void)_showPopinWindow {
    [self.class popinWindow].hidden = NO;
    [[self.class popinWindow] makeKeyAndVisible];
}

- (void)_hidePopinWindow {
    [self.class popinWindow].hidden = YES;
    [[self.class popinWindow] removeFromSuperview];
}

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

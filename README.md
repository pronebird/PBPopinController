# PBPopinController

Custom controller that pops from the bottom, exactly like keyboard.

![GIF Image](https://raw.githubusercontent.com/pronebird/PBPopinController/master/README%20Images/PopinController.gif)

#### Features

1. Content controller support.
2. Accessory view support.
3. Non-modal, creates its own UIWindow and passes through all user interactions within unoccupied by content area.
4. Plays nice with keyboard, e.g. hides itself if keyboard shows up, and vise-versa.
5. Dismisses on scroll if presented from table or collection view controller.
6. Uses same animation curve and duration as keyboard.
7. Knows how to swap content controller if already presented, without unnecessary animations.
8. Works with storyboards, use custom `PBPopinSegue`.

#### Known issues

1. Unwinding does not work. Manually dismiss controller.
2. Does not dismiss itself if presenting controller dismissed. Dismiss manually.

All contributions, PRs, comments are welcome!

### Installation using CocoaPods

Add the following line in your Podfile:

```ruby
pod 'PBPopinController'
```

### Example

#### Present a popin controller

```objective-c
#import <PBPopinController/PBPopinController.h>

@implementation MyViewController

- (IBAction)handleTapOnButton:(id)sender {
    UIViewController* contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ContentVC"];
    [[PBPopinController sharedPopinController] presentWithContentViewController:contentViewController
                                                             fromViewController:self
                                                                       animated:YES
                                                                     completion:nil];
}

@end

```

#### Dismiss a popin controller from anywhere

Popin controller is a singleton which means that you can always access it via `[PBPopinController sharedPopinController]`.

```objective-c

if([PBPopinController sharedPopinController].presented) {
    [[PBPopinController sharedPopinController] dismissAnimated:YES completion:nil];
}

```

#### Dismiss popin controller from content controller

Content controllers can access associated popin controller via `self.popinController`. This property is set to nil when content controller is about to be removed from popin container or replaced by another controller.

```objective-c

// Important to include this header
#import <PBPopinController/UIViewController+PopinController.h>

@implementation MyPopinContentViewController

- (IBAction)done:(id)sender {
    [self.popinController dismissAnimated:YES completion:nil];
}

@end

```

#### Content controller size

By default PopinController will use half of screen to present your content controller. However you can change that by setting a desired `preferredContentSize` on your content view controller.

#### Accessory view

You can provide an accessory view to popin controller which is placed above content view. Popin controller uses `intrinsicContentSize` to calculate size for accessory view.

Make sure you do not share the same accessory view with keyboard or any other view since it may lead to crash, e.g. keyboard explicitly checks for that and raises exception.

Although pop-in controller handles this properly when the same accessory view is shared between pop-in presentations.

```objc
// setup toolbar accessory view
UIToolbar* accessory = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
accessory.items = @[ /* ... */ ];

// create content controller
UIViewController* contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ContentVC"];

// assign accessory view
contentViewController.popinAccessoryView = accessory;

// present pop-in controller
[[PBPopinController sharedPopinController] presentWithContentViewController:contentViewController
                                                         fromViewController:self
                                                                   animated:YES
                                                                 completion:nil];
```

#### Storyboard

Popin controller comes with a custom segue `PBPopinSegue` that you can use to wire controllers in Storyboard. You still have to dismiss controller manually in code though.

Please take a look at demo app coming with this pod:

```bash
pod try PBPopinController
```

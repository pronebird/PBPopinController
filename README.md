# PBPopinController

Custom controller that pops from the bottom, exactly like keyboard.

![GIF Image](https://raw.githubusercontent.com/pronebird/PBPopinController/master/README%20Images/PopinController.gif)

#### Features

1. Content controller support.
2. Non-modal, creates its own UIWindow and passes through all user interactions within unoccupied by content area.
3. Plays nice with keyboard, e.g. hides itself if keyboard shows up, and vise-versa.
4. Dismisses on scroll if presented from table or collection view controller.
5. Uses same animation curve and duration as keyboard.
6. Knows how to swap content controller if already presented, without unnecessary animations.
7. Works with storyboards, use custom `PBPopinSegue`.

#### Known issues

1. May get stuck when presented and dismissed too fast. Race condition.
2. Unwinding does not work. Manually dismiss controller.
3. Does not dismiss itself if presenting controller dismissed. Dismiss manually.

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

It's not the best option, but the easiest to override `preferredContentSize`, for example:

```objective-c
- (CGSize)preferredContentSize {
    CGSize preferredSize;
    
    preferredSize.width = CGRectGetWidth(self.view.bounds);
    preferredSize.height = CGRectGetHeight(self.toolbar.bounds) + self.datePicker.intrinsicContentSize.height;
    
    return preferredSize;
}
```

#### Storyboard

Popin controller comes with a custom segue `PBPopinSegue` that you can use to wire controllers in Storyboard. You still have to dismiss controller manually in code though.

Please take a look at demo app coming with this pod:

```bash
pod try PBPopinController
```

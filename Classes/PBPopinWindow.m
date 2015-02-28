//
//  PBPopinWindow.m
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "PBPopinWindow.h"
#import "PBPopinContainerViewController.h"

@implementation PBPopinWindow

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    PBPopinContainerViewController* container = (PBPopinContainerViewController *)self.rootViewController;
    
    if(!CGRectContainsPoint(container.contentViewController.view.frame, point)) {
        return NO;
    }

    return YES;
}

@end

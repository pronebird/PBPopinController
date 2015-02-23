//
//  PBPopinSegue.m
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "PBPopinSegue.h"

@implementation PBPopinSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination {
    if(self = [super initWithIdentifier:identifier source:source destination:destination]) {
        self.popinController = [PBPopinController sharedPopinController];
    }
    return self;
}

- (void)perform {
    [self.popinController presentWithContentViewController:self.destinationViewController
                                        fromViewController:self.sourceViewController
                                                  animated:YES
                                                completion:nil];
}

@end

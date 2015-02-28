//
//  PBPopinSegue.m
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "PBPopinSegue.h"

@implementation PBPopinSegue

- (void)perform {
    [[PBPopinController sharedPopinController] presentWithContentViewController:self.destinationViewController
                                                             fromViewController:self.sourceViewController
                                                                       animated:YES
                                                                     completion:nil];
}

@end

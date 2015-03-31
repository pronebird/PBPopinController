//
//  PBModalPopinSegue.m
//  Pods
//
//  Created by pronebird on 3/31/15.
//
//

#import "PBModalPopinSegue.h"
#import "PBPopinController.h"

@implementation PBModalPopinSegue

- (void)perform {
    [[PBPopinController sharedPopinController] presentModalWithContentViewController:self.destinationViewController
                                                                  fromViewController:self.sourceViewController
                                                                            animated:YES
                                                                          completion:nil];
}

@end

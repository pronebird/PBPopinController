//
//  UIViewController+PopinController.h
//
//  Created by pronebird on 2/22/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBPopinController.h"

@interface UIViewController (PopinController)

/**
 *  An instance of popin controller presenting this view controller
 *  This property will be non-nil on content view controller when it is presented
 */
@property (readonly, nonatomic) PBPopinController* popinController;

@end

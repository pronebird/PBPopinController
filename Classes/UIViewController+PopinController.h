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
 *  This property is nil if controller is not presented
 */
@property (readonly, nonatomic) PBPopinController* popinController;

@end

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
 *  @abstract An instance of popin controller presenting this view controller.
 *  @discussion This property is nil if controller is not presented.
 */
@property (readonly, nonatomic) PBPopinController* popinController;

/**
 *  @abstract Get or set accessory view for popin.
 *  @discussion Accessory view is placed above content controller. It works the same way as inputAccessoryView on text fields.
 */
@property (nonatomic) UIView* popinAccessoryView;

@end

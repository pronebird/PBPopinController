//
//  DatePickerViewController.h
//  PBControllerDemo
//
//  Created by pronebird on 2/23/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickerViewController : UIViewController

@property (weak) IBOutlet UIDatePicker *datePicker;

@property (nonatomic) NSDate *currentDate;

@property (copy) void(^didChangeDate)(NSDate *date);

@end

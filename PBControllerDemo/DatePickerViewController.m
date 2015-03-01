//
//  DatePickerViewController.m
//  PBControllerDemo
//
//  Created by pronebird on 2/23/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "DatePickerViewController.h"

@implementation DatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.currentDate) {
        self.datePicker.date = self.currentDate;
    }
    
    // setup preferred size for controller
    self.preferredContentSize = self.datePicker.intrinsicContentSize;
}

- (void)setCurrentDate:(NSDate *)currentDate {
    if(![_currentDate isEqualToDate:currentDate]) {
        _currentDate = currentDate;
        [self.datePicker setDate:currentDate animated:YES];
    }
}

- (IBAction)datePickerDidChangeValue:(id)sender {
    self.currentDate = self.datePicker.date;
    
    if(self.didChangeDate) {
        self.didChangeDate(self.currentDate);
    }
}

@end

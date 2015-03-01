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
    
    if(self.initialDate) {
        self.datePicker.date = self.initialDate;
    }
    
    // setup preferred size for controller
    self.preferredContentSize = self.datePicker.intrinsicContentSize;
}

- (IBAction)datePickerDidChangeValue:(id)sender {
    if(self.didChangeDate) {
        self.didChangeDate(self.datePicker.date);
    }
}

@end

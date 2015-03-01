//
//  DatePickerViewController.m
//  PBControllerDemo
//
//  Created by pronebird on 2/23/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "DatePickerViewController.h"
#import "UIViewController+PopinController.h"

@implementation DatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.initialDate) {
        self.datePicker.date = self.initialDate;
    }
}

- (CGSize)preferredContentSize {
    CGSize preferredSize;
    
    preferredSize.width = CGRectGetWidth(self.view.bounds);
    preferredSize.height = self.datePicker.intrinsicContentSize.height;
    
    return preferredSize;
}

- (IBAction)datePickerDidChangeValue:(id)sender {
    if(self.didChangeDate) {
        self.didChangeDate(self.datePicker.date);
    }
}

- (IBAction)done:(id)sender {
    [self.popinController dismissAnimated:YES completion:nil];
}

@end

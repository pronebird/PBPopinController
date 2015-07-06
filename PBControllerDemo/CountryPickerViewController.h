//
//  CountryPickerViewController.h
//  PBControllerDemo
//
//  Created by pronebird on 2/23/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountryPickerViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak) IBOutlet UIPickerView *pickerView;

@property NSString *initialCountry;

@property (copy) void(^didSelectCountry)(NSString *country);

@end

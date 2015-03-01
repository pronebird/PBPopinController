//
//  TableViewController.h
//  PBControllerDemo
//
//  Created by pronebird on 2/23/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UITableViewController

@property (weak) IBOutlet UILabel* dateLabel;
@property (weak) IBOutlet UILabel* countryLabel;
@property (weak) IBOutlet UITextField* textField;
@property (weak) IBOutlet UIToolbar* popinAccessory;

@property NSDate* selectedDate;
@property NSString* selectedCountry;

@end

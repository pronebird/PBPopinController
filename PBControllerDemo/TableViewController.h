//
//  TableViewController.h
//  PBControllerDemo
//
//  Created by pronebird on 2/23/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UITableViewController<UITextFieldDelegate>

@property (weak) IBOutlet UILabel* dateLabel;
@property (weak) IBOutlet UILabel* countryLabel;
@property (weak) IBOutlet UITextField* textField;
@property (weak) IBOutlet UIToolbar* keyboardAccessory;
@property (strong) IBOutlet UIBarButtonItem* todayAccessoryItem;
@property (weak) IBOutlet UIToolbar* popinAccessory;
@property (weak) IBOutlet UIImageView *photoImageView;

@property NSDate* selectedDate;
@property NSString* selectedCountry;

@end

//
//  TableViewController.m
//  PBControllerDemo
//
//  Created by pronebird on 2/23/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "TableViewController.h"
#import "DatePickerViewController.h"
#import "CountryPickerViewController.h"
#import "UIViewController+PopinController.h"

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField.inputAccessoryView = self.popinAccessory;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ChooseDate"]) {
        DatePickerViewController* datePickerController = (DatePickerViewController*)segue.destinationViewController;
        datePickerController.initialDate = self.selectedDate;
        
        datePickerController.didChangeDate = ^(NSDate* date) {
            NSDateFormatter* dateFormatter = [NSDateFormatter new];
            dateFormatter.dateStyle = NSDateFormatterLongStyle;
            dateFormatter.timeStyle = NSDateFormatterNoStyle;
            
            self.dateLabel.text = [dateFormatter stringFromDate:date];
            self.selectedDate = date;
        };
        
        // setup accessory view
        datePickerController.popinAccessoryView = self.popinAccessory;
    } else if([segue.identifier isEqualToString:@"ChooseCategory"]) {
        CountryPickerViewController* countryPickerController = (CountryPickerViewController*)segue.destinationViewController;
        countryPickerController.initialCountry = self.selectedCountry;
        
        countryPickerController.didSelectCountry = ^(NSString* country) {
            self.countryLabel.text = country;
            self.selectedCountry = country;
        };
        
        countryPickerController.popinAccessoryView = self.popinAccessory;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)done:(id)sender {
    // dismiss keyboard
    [self.tableView endEditing:YES];
    
    // dismiss popin controller
    if([PBPopinController sharedPopinController].presented) {
        [[PBPopinController sharedPopinController] dismissAnimated:YES completion:nil];
    }
}

@end

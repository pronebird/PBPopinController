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

@implementation TableViewController

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
    } else if([segue.identifier isEqualToString:@"ChooseCategory"]) {
        CountryPickerViewController* countryPickerController = (CountryPickerViewController*)segue.destinationViewController;
        countryPickerController.initialCountry = self.selectedCountry;
        
        countryPickerController.didSelectCountry = ^(NSString* country) {
            self.countryLabel.text = country;
            self.selectedCountry = country;
        };
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

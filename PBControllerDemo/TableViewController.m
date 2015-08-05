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
#import "PictureViewController.h"
#import "PBPopinController.h"

@interface TableViewController()

@property (weak) DatePickerViewController* datePickerController;

@end

@implementation TableViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField.inputAccessoryView = self.keyboardAccessory;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ChooseDate"]) {
        [self handleDatePickerSegue:segue];
    }
    else if([segue.identifier isEqualToString:@"ChooseCategory"]) {
        [self handleCategoryPickerSegue:segue];
    }
    else if([segue.identifier isEqualToString:@"ChoosePhoto"]) {
        [self handlePicturePickerSegue:segue];
    }
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private

- (void)handleDatePickerSegue:(UIStoryboardSegue*)segue {
    DatePickerViewController* datePickerController = (DatePickerViewController*)segue.destinationViewController;
    datePickerController.currentDate = self.selectedDate;
    datePickerController.didChangeDate = ^(NSDate* date) {
        [self updateSelectedDate:date];
    };
    
    // add "today" button on toolbar
    NSMutableArray* toolbarItems = [self.popinAccessory.items mutableCopy];
    [toolbarItems removeObject:self.todayAccessoryItem];
    [toolbarItems insertObject:self.todayAccessoryItem atIndex:2];
    [self.popinAccessory setItems:toolbarItems];
    
    // setup accessory view
    datePickerController.popinAccessoryView = self.popinAccessory;
    
    self.datePickerController = datePickerController;
    
    [self.textField endEditing:YES];
}

- (void)handleCategoryPickerSegue:(UIStoryboardSegue*)segue {
    CountryPickerViewController* countryPickerController = (CountryPickerViewController*)segue.destinationViewController;
    countryPickerController.initialCountry = self.selectedCountry;
    countryPickerController.didSelectCountry = ^(NSString* country) {
        self.countryLabel.text = country;
        self.selectedCountry = country;
    };
    
    // remove "today" button from toolbar
    NSMutableArray* toolbarItems = [self.popinAccessory.items mutableCopy];
    [toolbarItems removeObject:self.todayAccessoryItem];
    [self.popinAccessory setItems:toolbarItems];
    
    // setup accessory view
    countryPickerController.popinAccessoryView = self.popinAccessory;
    
    [self.textField endEditing:YES];
}

- (void)handlePicturePickerSegue:(UIStoryboardSegue *)segue {
    PictureViewController *pictureController = (PictureViewController *)segue.destinationViewController;
    
    pictureController.didFinishPickingPhoto = ^(UIImage *image) {
        self.photoImageView.image = image;
    };
    
    [self.textField endEditing:YES];
}

- (void)updateSelectedDate:(NSDate*)date {
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    self.dateLabel.text = [dateFormatter stringFromDate:date];
    self.selectedDate = date;
}

#pragma mark - Actions

- (IBAction)today:(id)sender {
    self.datePickerController.currentDate = [NSDate date];
    [self updateSelectedDate:self.datePickerController.currentDate];
}

- (IBAction)done:(id)sender {
    // dismiss keyboard
    [self.tableView endEditing:YES];
    
    // dismiss popin controller
    [[PBPopinController sharedPopinController] dismissAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // dismiss popin controller
    [[PBPopinController sharedPopinController] dismissAnimated:YES completion:nil];
}

@end

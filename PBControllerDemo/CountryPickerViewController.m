//
//  CountryPickerViewController.m
//  PBControllerDemo
//
//  Created by pronebird on 2/23/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "CountryPickerViewController.h"

@interface CountryPickerViewController()

@property NSArray *countryList;

@end

@implementation CountryPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *identifier = [[NSLocale preferredLanguages] firstObject];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
    NSMutableArray *countryList = [NSMutableArray new];
    
    for(NSString *countryCode in [NSLocale ISOCountryCodes]) {
        NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
        [countryList addObject:displayNameString];
    }

    self.countryList = [countryList sortedArrayUsingSelector:@selector(localizedCompare:)];
    
    if(self.initialCountry) {
        NSUInteger index = [self.countryList indexOfObject:self.initialCountry];
        if(index != NSNotFound) {
            [self.pickerView selectRow:index inComponent:0 animated:NO];
        }
    }
    
    // setup preferred size for controller
    self.preferredContentSize = self.pickerView.intrinsicContentSize;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    self.preferredContentSize = self.pickerView.intrinsicContentSize;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.countryList.count;
}

#pragma marl - UIPickerViewDelegate

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.countryList[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(self.didSelectCountry) {
        self.didSelectCountry(self.countryList[row]);
    }
}

@end

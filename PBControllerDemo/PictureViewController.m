//
//  PictureViewController.m
//  PBControllerDemo
//
//  Created by pronebird on 3/31/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "PictureViewController.h"
#import "PBPopinController.h"
#import "UIViewController+PopinController.h"

@interface PictureViewController ()

@property UIImagePickerController *imagePicker;

@end

@implementation PictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addChildViewController:self.imagePicker];
    [self.view addSubview:self.imagePicker.view];
    [self.imagePicker didMoveToParentViewController:self];
    
    NSDictionary *viewsDictionary = @{ @"imagePicker": self.imagePicker.view };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imagePicker]|" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imagePicker]|" options:0 metrics:nil views:viewsDictionary]];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if(self.didFinishPickingPhoto) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        self.didFinishPickingPhoto(image);
    }
    [self.popinController dismissAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.popinController dismissAnimated:YES completion:nil];
}

@end

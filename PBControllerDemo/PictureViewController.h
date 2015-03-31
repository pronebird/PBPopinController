//
//  PictureViewController.h
//  PBControllerDemo
//
//  Created by pronebird on 3/31/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (copy) void(^didFinishPickingPhoto)(UIImage *image);

@end

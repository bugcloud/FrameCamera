//
//  ViewController.h
//  FrameCamera
//
//  Created by Nagino Yuki on 2012/12/07.
//  Copyright (c) 2012年 RaD Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "CameraViewController.h"

@interface ViewController : UIViewController <UIImagePickerControllerDelegate/*, CameraViewControllerDelegate*/> {
    UIButton *cameraButton_;
    CameraViewController *cameraViewController_;
}

@property (nonatomic, retain) IBOutlet UIButton *cameraButton_;
@property (nonatomic, retain) CameraViewController *cameraViewController_;

- (IBAction)cameraAction:(id)sender;

@end

//
//  CameraViewController.h
//  FrameCamera
//
//  Created by Nagino Yuki on 2012/12/07.
//  Copyright (c) 2012年 RaD Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingViewController.h"
#import "ImageView.h"

@protocol CameraViewControllerDelegate;

@interface CameraViewController : UIViewController <
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIScrollViewDelegate,
SettingViewControllerDelegate
> {
    __unsafe_unretained id <CameraViewControllerDelegate> delegate;
    UIImagePickerController *imagePickerController_;
    UIScrollView *scrollView_;
    SettingViewController *settingViewController_;
    UILabel *dateLabel_;
    UIButton *hideFrameButton_;
    UIButton *settingButton_;
    UIImageView *gridImageView_;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView_;
@property (nonatomic, assign) id <CameraViewControllerDelegate> delegate;
@property (nonatomic, retain) UIImagePickerController *imagePickerController_;
@property (nonatomic, assign) NSInteger frameIndex_;
@property (nonatomic, retain) NSArray *frameImages_;
@property (nonatomic, retain) SettingViewController *settingViewController_;
@property (nonatomic, retain) UILabel *dateLabel_;
@property (nonatomic, retain) UIButton *hideFrameButton_;
@property (nonatomic, retain) UIButton *settingButton_;
@property (nonatomic, retain) UIImageView *gridImageView_;

- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType;

@end

@protocol CameraViewControllerDelegate
- (void)didTakePicture:(UIImage *)picture pushToCameraRoll:(BOOL)willSave;
- (void)didFinishWithCamera;
@end

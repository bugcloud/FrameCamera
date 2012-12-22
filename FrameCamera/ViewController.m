//
//  ViewController.m
//  FrameCamera
//
//  Created by Nagino Yuki on 2012/12/07.
//  Copyright (c) 2012年 RaD Inc. All rights reserved.
//

#import "ViewController.h"

#define LOG(A, ...) NSLog(@"DEBUG: %s:%d:%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);

@interface ViewController ()

@end

@implementation ViewController

@synthesize cameraViewController_, cameraButton_;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.cameraViewController_ = [[CameraViewController alloc] initWithNibName:@"CameraViewController"
                                                                        bundle:[NSBundle mainBundle]
                                  ];
    self.cameraViewController_.delegate = (id)self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Button Actions
- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        [self.cameraViewController_ setupImagePicker:sourceType];
        [self presentViewController:self.cameraViewController_.imagePickerController_  animated:YES completion:^{}];
    }
}

- (IBAction)cameraAction:(id)sender
{
    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
}

#pragma mark -
#pragma mark CameraViewControllerDelegate

- (void)didTakePicture:(UIImage *)picture pushToCameraRoll:(BOOL)willSave metaData:(NSDictionary *)info
{
    if (willSave) {
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        NSMutableDictionary *meta = [[info objectForKey:UIImagePickerControllerMediaMetadata] mutableCopy];
        // Remove orientation information from metadata
        [meta removeObjectForKey:@"Orientation"];
        
        // Set Frame No to Exif info
        NSString *exifKey = @"{Exif}";
        NSMutableDictionary *metaExif = [meta objectForKey:exifKey];
        [metaExif setObject:[NSString stringWithFormat:@"%d", (self.cameraViewController_.frameIndex_ + 1)]
                     forKey:@"FrameNo"];
        [meta setObject:metaExif forKey:exifKey];
        
        //LOG([meta description]);
        [lib writeImageToSavedPhotosAlbum:picture.CGImage
                                 metadata:meta
                          completionBlock:^(NSURL* url, NSError* error){
                              [self dismissViewControllerAnimated:YES completion:nil];
                          }
        ];
    }
}

- (void)didFinishWithCamera
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

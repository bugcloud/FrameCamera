//
//  ViewController.m
//  FrameCamera
//
//  Created by Nagino Yuki on 2012/12/07.
//  Copyright (c) 2012年 RaD Inc. All rights reserved.
//

#import "ViewController.h"
#import "Macros.h"
#import "MBProgressHUD.h"

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
        NSDictionary *meta = [info objectForKey:UIImagePickerControllerMediaMetadata];
        [lib writeImageToSavedPhotosAlbum:picture.CGImage
                                 metadata:[self customizeJPEGMetaData:meta]
                          completionBlock:^(NSURL* url, NSError* error){
                              [self dismissViewControllerAnimated:YES completion:^(){
                                  [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
                              }];
                          }
        ];
        [MBProgressHUD hideHUDForView:self.cameraViewController_.view animated:YES];
    }
}

- (NSMutableDictionary *)customizeJPEGMetaData:(NSDictionary *)metaData
{
    NSMutableDictionary *meta = [metaData mutableCopy];
    // Remove orientation information from metadata
    [meta removeObjectForKey:@"Orientation"];
    
    // Set Frame No to Exif info
    NSString *exifKey = (NSString*)kCGImagePropertyExifDictionary;
    NSMutableDictionary *metaExif = [meta objectForKey:exifKey];
    [metaExif setObject:[NSString stringWithFormat:@"Frame number is %d", (self.cameraViewController_.frameIndex_ + 1)]
                 forKey:(NSString*)kCGImagePropertyExifUserComment];
    [meta setObject:metaExif forKey:exifKey];
    
    // Set GPS meta data
    NSString *gpsKey = (NSString*)kCGImagePropertyGPSDictionary;
    NSMutableDictionary *metaGps = [NSMutableDictionary dictionaryWithCapacity:0];
    CLLocation *loc = self.cameraViewController_.currentLocation_;
    CLLocationDegrees lat = loc.coordinate.latitude;
    CLLocationDegrees lng = loc.coordinate.longitude;
    NSString *latRef;
    NSString *lngRef;
    if (lat < 0.0) {
        lat = lat * -1.0f;
        latRef = @"S";
    } else {
        latRef = @"N";
    }
    if (lng < 0.0) {
        lng = lng * -1.0f;
        lngRef = @"W";
    } else {
        lngRef = @"E";
    }
    [metaGps setObject:latRef forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    [metaGps setObject:lngRef forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    [metaGps setObject:[NSNumber numberWithFloat:loc.coordinate.latitude]
                forKey:(NSString*)kCGImagePropertyGPSLatitude];
    [metaGps setObject:[NSNumber numberWithFloat:loc.coordinate.longitude]
                forKey:(NSString*)kCGImagePropertyGPSLongitude];
    [metaGps setObject:loc.timestamp
                forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
    [metaGps setObject:[NSNumber numberWithFloat:loc.horizontalAccuracy]
                forKey:(NSString*)kCGImagePropertyGPSDOP];
    [metaGps setObject:[NSNumber numberWithFloat:loc.altitude]
                forKey:(NSString*)kCGImagePropertyGPSAltitude];
    [meta setObject:metaGps forKey:gpsKey];
    
    //LOG([meta description]);
    return meta;
}

- (void)didFinishWithCamera
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

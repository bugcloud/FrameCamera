//
//  CameraViewController.m
//  FrameCamera
//
//  Created by Nagino Yuki on 2012/12/07.
//  Copyright (c) 2012年 RaD Inc. All rights reserved.
//

#import "CameraViewController.h"
#import "Macros.h"
#import "MBProgressHUD.h"
#import "UIImage+H568.h"

@interface CameraViewController ()

@end

@implementation CameraViewController

@synthesize delegate, scrollView_, imagePickerController_,
frameIndex_, frameImages_, settingViewController_,
dateLabel_, hideFrameButton_, settingButton_, gridImageView_,
locationManager_, currentLocation_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.settingViewController_ = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
        self.settingViewController_.delegate = (id)self;
        
        self.imagePickerController_ = [[UIImagePickerController alloc] init];
        self.imagePickerController_.delegate = self;
        //add current date
        NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
        [dtf setDateFormat:@"yyyy/MM/dd"];
        //TODO set size
        self.dateLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(222, 10, 150, 20)];
        [self.dateLabel_ setFont:[UIFont boldSystemFontOfSize:16]];
        [self.dateLabel_ setTextColor:[UIColor whiteColor]];
        [self.dateLabel_ setBackgroundColor:[UIColor clearColor]];
        [self.dateLabel_ setText:[dtf stringFromDate:[NSDate date]]];
        [self.view addSubview:self.dateLabel_];
        
        //initialization of UIScrollView
        scrollView_.pagingEnabled = YES;
        scrollView_.showsHorizontalScrollIndicator = NO;
        scrollView_.showsVerticalScrollIndicator = NO;
        scrollView_.scrollsToTop = NO;
        scrollView_.delegate = self;
        [self updateFrameImages];
        
        // Add the hide frame button
        self.hideFrameButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        self.hideFrameButton_.frame = CGRectMake(266, 55, 48, 49);
        UIImage *buttonImageNormal = [UIImage imageNamed:@"btn_frame"];
        UIImage *buttonImagePushed = [UIImage imageNamed:@"btn_frame_push"];
        [self.hideFrameButton_ setAlpha:0.5f];
        [self.hideFrameButton_ setImage:buttonImageNormal forState:UIControlStateNormal];
        [self.hideFrameButton_ setImage:buttonImageNormal forState:UIControlStateDisabled];
        [self.hideFrameButton_ setImage:buttonImagePushed forState:UIControlEventTouchDown];
        [self.hideFrameButton_ addTarget:self action:@selector(toggleFrame:) forControlEvents:UIControlEventTouchUpInside];
        [self.imagePickerController_.view addSubview: self.hideFrameButton_];
        
        // Add the setting button
        self.settingButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        self.settingButton_.frame = CGRectMake(266, 105, 48, 49);
        UIImage *settingButtonImageNormal = [UIImage imageNamed:@"btn_setting"];
        UIImage *settingButtonImagePushed = [UIImage imageNamed:@"btn_setting_push"];
        [self.settingButton_ setAlpha:0.5f];
        [self.settingButton_ setImage:settingButtonImageNormal forState:UIControlStateNormal];
        [self.settingButton_ setImage:settingButtonImageNormal forState:UIControlStateDisabled];
        [self.settingButton_ setImage:settingButtonImagePushed forState:UIControlEventTouchDown];
        [self.settingButton_ addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchUpInside];
        [self.imagePickerController_.view addSubview:self.settingButton_];
        
        // Add the grid view
        self.gridImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grid"]];
        [self.imagePickerController_.view addSubview:self.gridImageView_];
        [self.gridImageView_ setHidden:YES];
        
        [self updateOverLayFrame];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.locationManager_ == nil) {
        self.locationManager_ = [[CLLocationManager alloc] init];
    }
    self.locationManager_.delegate = self;
    [self.locationManager_ startMonitoringSignificantLocationChanges];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    self.imagePickerController_.sourceType = sourceType;
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        self.imagePickerController_.showsCameraControls = YES;
        [self.imagePickerController_.cameraOverlayView addSubview:self.view];
        [self.hideFrameButton_ setHidden:NO];
        [self.settingButton_ setHidden:NO];
    } else {
        [self.hideFrameButton_ setHidden:YES];
        [self.settingButton_ setHidden:YES];
    }
}

- (void)updateOverLayFrame
{
    if (!self.settingViewController_.valueForDateVisibleSetting_) {
        [self.dateLabel_ setHidden:YES];
    } else {
        [self.dateLabel_ setHidden:NO];
    }
    if (!self.settingViewController_.valueForGridVisibleSetting_) {
        [self.gridImageView_ setHidden:YES];
    } else {
        [self.gridImageView_ setHidden:NO];
    }
}

-(void)updateFrameImages
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents;
    BOOL useDefaultBundle = self.settingViewController_.valueForUserNameSetting_ == nil ||
    [self.settingViewController_.valueForUserNameSetting_ length] <= 0;
    if (useDefaultBundle) {
        contents = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:nil];
    } else {
        contents = [fileManager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                                                    error:nil];
    }
    
    NSMutableArray *imgs = [NSMutableArray array];
    for (NSString __strong *filePath in contents) {
        if (useDefaultBundle) {
            filePath = [[filePath componentsSeparatedByString:@"/"] lastObject];
        }
        if ([filePath hasPrefix:@"frame"] && [filePath rangeOfString:@"@"].length == 0) {
            if (useDefaultBundle) {
                [imgs addObject:[UIImage imageNamed:filePath]];
            } else {
                filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                            stringByAppendingPathComponent:filePath];
                [imgs addObject:[UIImage imageWithContentsOfFile:filePath]];
            }
        }
    }
    self.frameImages_ = [NSArray arrayWithArray:imgs];
    self.frameIndex_ = 0;
    scrollView_.contentSize = CGSizeMake(
                                         scrollView_.frame.size.width * [self.frameImages_ count],
                                         scrollView_.frame.size.height
                                         );
    ImageView *iv = [[ImageView alloc] initWithFrame:CGRectMake(
                                                                0,
                                                                0,
                                                                self.view.frame.size.width * [self.frameImages_ count],
                                                                self.view.frame.size.height
                                                                )
                     ];
    iv.imageList_ = self.frameImages_;
    iv.backgroundColor = [UIColor clearColor];
    for (UIView *view in self.scrollView_.subviews) {
        [view removeFromSuperview];
    }
    [self.scrollView_ addSubview:iv];
}

- (void)toggleFrame:(id)sender
{
    if (self.view.frame.size.width == 0) {
        [self resetFrameSize];
    } else {
        //This line is need to make the default camera control buttons enabled
        self.view.frame = CGRectZero;
    }
}

-(void)resetFrameSize
{
    // Reset frame size
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    self.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height - statusBarRect.size.height);
}

- (void)showSetting:(id)sender
{
    // Show frame forcibly when showing setting view
    // If frame is invisible(self.view.frame == CGRectZero),
    // resetting frame images on scrollview will be failed
    if (self.view.frame.size.width == 0) {
        [self resetFrameSize];
    }
    
    CGSize screenCenter = [UIScreen mainScreen].bounds.size;
    CGPoint offScreenCenter = CGPointMake(screenCenter.width / 2.0, screenCenter.height * 1.5);
    self.settingViewController_.view.center = offScreenCenter;
    [self.imagePickerController_.view addSubview:self.settingViewController_.view];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.settingViewController_.view.center = CGPointMake(screenCenter.width / 2.0, screenCenter.height / 2.0);
    [UIView commitAnimations];
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Show loading view and call delegate to save image
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        BOOL willSave = NO;
        if (self.imagePickerController_.sourceType == UIImagePickerControllerSourceTypeCamera) {
            CGSize size = [image size];
            UIGraphicsBeginImageContext(size);
            CGRect rect;
            rect.origin = CGPointZero;
            rect.size = size;
            
            [image drawInRect:rect];
            [[self.frameImages_ objectAtIndex:self.frameIndex_] drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
            
            //add current date
            //TODO I should set the position of date dynamically
            if (self.settingViewController_.valueForDateVisibleSetting_) {
                NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
                [dtf setDateFormat:@"yyyy/MM/dd"];
                [[UIColor whiteColor] set];
                int y = 72;
                int fontSize = 96;
                if (rect.size.width > 1936) {
                    y = 100;
                    fontSize = 110;
                }
                [[dtf stringFromDate:[NSDate date]] drawInRect:CGRectMake(rect.size.width * 0.69, y, rect.size.width, rect.size.height) withFont:[UIFont boldSystemFontOfSize:fontSize]];
            }
            
            UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            image = mergedImage;
            willSave = YES;
        }
        if (self.delegate)
            [self.delegate didTakePicture:image pushToCameraRoll:willSave metaData:info];
    });
    /* Hide ProgressHUD in ViewController.m
       - (void)didTakePicture:(UIImage *)picture pushToCameraRoll:(BOOL)willSave metaData:(NSDictionary *)info
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
     */
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.delegate didFinishWithCamera];    // tell our delegate we are finished with the picker
}


#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = scrollView_.frame.size.width;
    self.frameIndex_ = floor((scrollView_.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [self updateOverLayFrame];
}


#pragma mark -
#pragma mark SettingViewControllerDelegate

- (void) didFinishSavingSettings
{
    CGSize screenCenter = [UIScreen mainScreen].bounds.size;
    CGPoint offScreenCenter = CGPointMake(screenCenter.width / 2.0, screenCenter.height * 1.5);
    [self.imagePickerController_.view addSubview:self.settingViewController_.view];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeSettingView:)];
    self.settingViewController_.view.center = offScreenCenter;
    [UIView commitAnimations];
    
    [self updateFrameImages];
    [self updateOverLayFrame];
}

-(void) removeSettingView
{
    [self.settingViewController_.view removeFromSuperview];
}


#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation_ = [locations lastObject];
}

@end
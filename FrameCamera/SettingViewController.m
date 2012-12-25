//
//  SettingViewController.m
//  FrameCamera
//
//  Created by Nagino Yuki on 2012/12/07.
//  Copyright (c) 2012年 RaD Inc. All rights reserved.
//

#import "SettingViewController.h"
#import "JSONKit.h"
#import "Macros.h"
#import "MBProgressHUD.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

@synthesize delegate, keyForDateVisibleSetting_, keyForGridVisibleSetting_, keyForUserNameSetting_,
valueForDateVisibleSetting_, valueForGridVisibleSetting_, valueForUserNameSetting_,
switchForDateVisibleSetting_, switchForGridVisibleSetting_, textFieldForNameSetting_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.keyForDateVisibleSetting_ = @"KEY_SETTING_DATE_VISIBLE";
        self.keyForGridVisibleSetting_ = @"KEY_SETTING_GRID_VISIBLE";
        self.keyForUserNameSetting_ = @"KEY_SETTING_USER_NAME";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.valueForDateVisibleSetting_ = [defaults boolForKey:self.keyForDateVisibleSetting_];
        self.valueForGridVisibleSetting_ = [defaults boolForKey:self.keyForGridVisibleSetting_];
        self.valueForUserNameSetting_ = [defaults stringForKey:self.keyForUserNameSetting_];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.textFieldForNameSetting_ setText:self.valueForUserNameSetting_];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveSettings:(id)sender
{
    // Hide keyboard
    [self textFieldShouldReturn:self.textFieldForNameSetting_];
    // Show loading view and fetch images
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do asynchronous process
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL userNameHasUpdated = self.valueForUserNameSetting_ != [defaults stringForKey:self.keyForUserNameSetting_];
        [defaults setBool:self.valueForDateVisibleSetting_ forKey:self.keyForDateVisibleSetting_];
        [defaults setBool:self.valueForGridVisibleSetting_ forKey:self.keyForGridVisibleSetting_];
        [defaults setObject:self.valueForUserNameSetting_ forKey:self.keyForUserNameSetting_];
        [defaults synchronize];
        
        if (
            self.valueForUserNameSetting_ != nil &&
            [self.valueForUserNameSetting_ length] > 0 &&
            userNameHasUpdated
            ) {
            // Remove all file
            NSFileManager *fileManager = [NSFileManager defaultManager];
            for (NSString *p in [fileManager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] error:nil]) {
                NSString *rmFile = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:p];
                [fileManager removeItemAtPath:rmFile error:NULL];
            }
            
            // Fetch resources' json
            NSURL *jsonUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://rad.bugcloud.com/%@/resources.js", self.valueForUserNameSetting_]];
            NSData *jsonData = [NSData dataWithContentsOfURL:jsonUrl];
            // Show alert unless app could get json data
            if (jsonData == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"failed_to_fetch_images", nil)
                                                message:NSLocalizedString(@"please_check_your_username", nil)
                                               delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                      otherButtonTitles:NSLocalizedString(@"ok", nil), nil
                      ] show];
                });

            } else {
                NSObject *jsonObj = [[JSONDecoder decoder] mutableObjectWithData:jsonData];
                NSMutableArray *resourceUrls = [NSMutableArray arrayWithCapacity:0];
                for (NSDictionary *dict in [jsonObj valueForKey:@"frames"]) {
                    [resourceUrls addObject:[dict objectForKey:@"img_normal"]];
                    [resourceUrls addObject:[dict objectForKey:@"img_2x"]];
                    [resourceUrls addObject:[dict objectForKey:@"img_568h"]];
                }
                
                // Fetch images according to JSON
                for (NSString __strong *url in resourceUrls) {
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                    //NSString *newFileName = [[url lastPathComponent] stringByDeletingPathExtension];
                    NSString *newFile = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[url lastPathComponent]];
                    if (![imgData writeToFile:newFile atomically:YES]) {
                        //TODO
                        // Do something when app could not save image files
                        LOG(@"failed to save");
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (self.delegate) {
                [self.delegate didFinishSavingSettings];
            }
        });
    });
}

- (IBAction)didSwitchForDateVisibleSettingChanged:(id)sender
{
    self.valueForDateVisibleSetting_ = ([sender isOn])? YES : NO;
}

- (IBAction)didSwitchForGridVisibleSettingChanged:(id)sender
{
    self.valueForGridVisibleSetting_ = ([sender isOn])? YES : NO;
}


#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    self.valueForUserNameSetting_ = textFieldForNameSetting_.text;
    [self.textFieldForNameSetting_ resignFirstResponder];
    return YES;
}

@end

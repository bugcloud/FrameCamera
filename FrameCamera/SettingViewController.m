//
//  SettingViewController.m
//  FrameCamera
//
//  Created by Nagino Yuki on 2012/12/07.
//  Copyright (c) 2012年 RaD Inc. All rights reserved.
//

#import "SettingViewController.h"
#import "Macros.h"

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
        [self.textFieldForNameSetting_ setText:self.valueForUserNameSetting_];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.valueForDateVisibleSetting_ forKey:self.keyForDateVisibleSetting_];
    [defaults setBool:self.valueForGridVisibleSetting_ forKey:self.keyForGridVisibleSetting_];
    [defaults setObject:self.valueForUserNameSetting_ forKey:self.keyForUserNameSetting_];
    [defaults synchronize];
    
    if (self.delegate) {
        [self.delegate didFinishSavingSettings];
    }
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

//
//  SettingViewController.m
//  FrameCamera
//
//  Created by Nagino Yuki on 2012/12/07.
//  Copyright (c) 2012年 RaD Inc. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

@synthesize delegate, keyForDateVisibleSetting_, keyForGridVisibleSetting_,
valueForDateVisibleSetting_, valueForGridVisibleSetting_,
switchForDateVisibleSetting_, switchForGridVisibleSetting_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.keyForDateVisibleSetting_ = @"KEY_SETTING_DATE_VISIBLE";
        self.keyForGridVisibleSetting_ = @"KEY_SETTING_GRID_VISIBLE";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.valueForDateVisibleSetting_ = [defaults boolForKey:self.keyForDateVisibleSetting_];
        self.valueForGridVisibleSetting_ = [defaults boolForKey:self.keyForGridVisibleSetting_];
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.valueForDateVisibleSetting_ forKey:self.keyForDateVisibleSetting_];
    [defaults setBool:self.valueForGridVisibleSetting_ forKey:self.keyForGridVisibleSetting_];
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

@end

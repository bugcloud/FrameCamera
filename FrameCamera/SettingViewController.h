//
//  SettingViewController.h
//  FrameCamera
//
//  Created by Nagino Yuki on 2012/12/07.
//  Copyright (c) 2012年 RaD Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>

@protocol SettingViewControllerDelegate;

@interface SettingViewController : UIViewController {
    __unsafe_unretained id <SettingViewControllerDelegate> delegate;
    NSString *keyForDateVisibleSetting_;
    NSString *keyForGridVisibleSetting_;
    BOOL valueForDateVisibleSetting_;
    BOOL valueForGridVisibleSetting_;
}

@property (nonatomic, assign) id <SettingViewControllerDelegate> delegate;
@property (nonatomic, retain) NSString *keyForDateVisibleSetting_;
@property (nonatomic, retain) NSString *keyForGridVisibleSetting_;
@property (nonatomic, assign) BOOL valueForDateVisibleSetting_;
@property (nonatomic, assign) BOOL valueForGridVisibleSetting_;
@property (nonatomic, retain) IBOutlet UISwitch *switchForDateVisibleSetting_;
@property (nonatomic, retain) IBOutlet UISwitch *switchForGridVisibleSetting_;

- (IBAction)saveSettings:(id)sender;
- (IBAction)didSwitchForDateVisibleSettingChanged:(id)sender;
- (IBAction)didSwitchForGridVisibleSettingChanged:(id)sender;

@end

@protocol SettingViewControllerDelegate
- (void) didFinishSavingSettings;
@end

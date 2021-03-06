//
//  DVSPasswordChangeViewController.m
//  Devise
//
//  Created by Wojciech Trzasko on 12.12.2014.
//  Copyright (c) 2014 Netguru Sp. z o.o. All rights reserved.
//

#import "DVSDemoPasswordChangeViewController.h"
#import <Devise/Devise.h>

#import "DVSDemoUser.h"
#import "DVSDemoUserDataSource.h"
#import "NSError+DeviseDemo.h"
#import "UIAlertView+DeviseDemo.h"

static NSString * const DVSTitleForAlertCancelButton = @"Close";
static NSString * const DVSTitleForCurrentPassword = @"Current password";
static NSString * const DVSTitleForNewPassword = @"New password";
static NSString * const DVSTitleForConfirmNewPassword = @"Confirm new password";

@interface DVSDemoPasswordChangeViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) DVSDemoUserDataSource *userDataSource;

@end

@implementation DVSDemoPasswordChangeViewController

#pragma mark - Object lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userDataSource = [DVSDemoUserDataSource new];
    
    [self addFormWithTitleToDataSource:NSLocalizedString(DVSTitleForCurrentPassword, nil)
                    accessibilityLabel:DVSAccessibilityLabel(@"Current password field")
                               secured:YES];
    [self addFormWithTitleToDataSource:NSLocalizedString(DVSTitleForNewPassword, nil)
                    accessibilityLabel:DVSAccessibilityLabel(@"New password field")
                               secured:YES];
    [self addFormWithTitleToDataSource:NSLocalizedString(DVSTitleForConfirmNewPassword, nil)
                    accessibilityLabel:DVSAccessibilityLabel(@"Confirm password field")
                               secured:YES];
}

#pragma mark - UIControl events

- (IBAction)saveButtonTapped:(UIBarButtonItem *)sender {
    DVSDemoUser *localUser = [DVSDemoUser localUser];
    
    localUser.dataSource = self.userDataSource;
    
    NSString *currentPassword = localUser.password;
    
    NSString *currentPasswordConfirm = [self valueForTitle:NSLocalizedString(DVSTitleForCurrentPassword, nil)];
    if ([currentPasswordConfirm isEqualToString:@""]) {
        [[UIAlertView dvs_alertViewForError:[NSError dvs_currentPasswordRequiredError]] show];
        return;
    }
    
    if (![currentPassword isEqualToString:currentPasswordConfirm]) {
        [[UIAlertView dvs_alertViewForError:[NSError dvs_passwordConfirmError]] show];
        return;
    }
    
    NSString *newPassword = [self valueForTitle:NSLocalizedString(DVSTitleForNewPassword, nil)];
    NSString *newPasswordConfirm = [self valueForTitle:NSLocalizedString(DVSTitleForConfirmNewPassword, nil)];
    
    if ([newPassword isEqualToString:@""]) {
        [[UIAlertView dvs_alertViewForError:[NSError dvs_newPasswordRequiredError]] show];
        return;
    }
    
    if ([newPasswordConfirm isEqualToString:@""]) {
        [[UIAlertView dvs_alertViewForError:[NSError dvs_newPasswordConfirmRequiredError]] show];
        return;
    }
    
    if (![newPassword isEqualToString:newPasswordConfirm]) {
        [[UIAlertView dvs_alertViewForError:[NSError dvs_newPasswordConfirmMatchError]] show];
        return;
    }
    
    localUser.password = newPassword;
    
    [localUser changePasswordWithSuccess:^{
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password changed", nil)
                                    message:NSLocalizedString(@"Password was changed. \nNow you can login with new password.", nil)
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(DVSTitleForAlertCancelButton, nil)
                          otherButtonTitles:nil] show];
    } failure:^(NSError *error) {
        localUser.password = currentPassword;
        [[UIAlertView dvs_alertViewForError:error] show];
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:NSLocalizedString(DVSTitleForAlertCancelButton, nil)]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

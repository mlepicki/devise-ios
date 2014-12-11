//
//  ProfileEditorViewController.m
//  Devise
//
//  Created by Grzegorz Lesiak on 20/11/14.
//  Copyright (c) 2014 Netguru.co. All rights reserved.
//

#import "DVSProfileEditorViewController.h"
#import <Devise/Devise.h>

#import "DVSUserViewController.h"
#import "UIAlertView+Devise.h"

static NSString * const DVSUserViewSegue = @"EmbedUserView";

@interface DVSProfileEditorViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewBottomConstraint;
@property (strong, nonatomic) DVSUserViewController *userViewController;

@end

@implementation DVSProfileEditorViewController

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardSizeChanged:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardSizeChanged:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.userViewController fillWithUser:[DVSUser localUser]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - Notifications

- (void)keyboardSizeChanged:(NSNotification*)notification {
    CGRect keyboardEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardBeginFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    if (keyboardBeginFrame.origin.y > keyboardEndFrame.origin.y) {
        self.containerViewBottomConstraint.constant = keyboardBeginFrame.size.height;
    } else {
        self.containerViewBottomConstraint.constant = 0;
    }
}

#pragma mark - Touch

- (IBAction)saveButtonTouched:(UIBarButtonItem *)sender {
    DVSUser *localUser = [DVSUser localUser];
    
    localUser.username = self.userViewController.usernameTextField.text;
    localUser.email = self.userViewController.emailTextField.text;
    localUser.firstName = self.userViewController.firstNameTextField.text;
    localUser.lastName = self.userViewController.lastNameTextField.text;
    localUser.phone = self.userViewController.phoneTextField.text;
    
    [localUser updateWithSuccess:^{
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [UIAlertView dvs_alertViewForError:error];
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:DVSUserViewSegue]) {
        self.userViewController = (DVSUserViewController *)segue.destinationViewController;
    }
}

@end
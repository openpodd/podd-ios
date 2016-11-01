//
//  LoginViewController.m
//  poddreport
//
//  Created by Opendream-iOS on 2/2/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "LoginViewController.h"
#import "ReportAppDelegate.h"

#import "LoginCommand.h"
#import "ConfigurationCommand.h"
#import "ConfigurationManager.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic, nullable) IBOutlet UITextField *username;
@property (weak, nonatomic, nullable) IBOutlet UITextField *password;
@property (weak, nonatomic, nullable) IBOutlet UIView *loadingView;
@property (weak, nonatomic, nullable) IBOutlet UIView *contentView;
@property (weak, nonatomic, nullable) IBOutlet UIButton *loginButton;
@property (weak, nonatomic, nullable) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic, nullable) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@end

@interface LoginViewController (Keyboard)
- (void)setupKeyboardObservers;
- (void)removeKeyboardObservers;
@end

@implementation LoginViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.loginButton.layer.cornerRadius = 20;
}

- (void) viewWillAppear:(BOOL)animated {
    
    [[self navigationController] setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
    [self setupKeyboardObservers];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self removeKeyboardObservers];
}

- (IBAction)register:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Registration" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"invitationViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [[self navigationController] pushViewController:vc animated:YES];
}

- (IBAction)login:(id)sender {
    
    [self resignFirstResponder];
    
    if (self.username.text.length > 0 && self.password.text.length > 0) {
        [self performCommand];
        
    } else {
        [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate]
         presentAlerWithTitle:NSLocalizedString(@"LoginErrorTitle", nil)
         withMessage:NSLocalizedString(@"LoginErrorInformationNeeded", nil)];
    }
}

- (BOOL)resignFirstResponder {
    
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    return [super resignFirstResponder];
}

- (void)performCommand {
    
    self.loadingView.alpha = 1;
    
    LoginCommand *loginCommand = [[LoginCommand alloc] initWithConfiguration:[ConfigurationManager sharedConfiguration]];
    [loginCommand setUsername:self.username.text withPassword:self.password.text];
    [loginCommand setCompletionBlock:^(NSDictionary *params) {
        ConfigurationCommand *configurationCommand = [[ConfigurationCommand alloc] initWithConfiguration:[ConfigurationManager sharedConfiguration]];
        configurationCommand.data = [ConfigurationManager sharedConfiguration].deviceInformation;
        [configurationCommand setCompletionBlock:^(NSDictionary *params){
            [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate] setupAWS];
            [self performSelectorOnMainThread:@selector(didLoginSuccessfully) withObject:nil waitUntilDone:NO];
            
        }];
        
        [configurationCommand start];
    }];
    
    [loginCommand setFailedBlock:^(NSError *error) {
        
        [self performSelectorOnMainThread:@selector(didLoginFailed:) withObject:error waitUntilDone:NO];
    }];
    
    [loginCommand start];
}

- (void)didLoginFailed:(NSError * _Nonnull)error {
    
    self.loadingView.alpha = 0; 
    
    if ([error.domain isEqualToString:PODDDomain]) {
        NSString *errorCode = [NSString stringWithFormat:@"%tu", error.code];
        [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate]
         presentAlerWithTitle:NSLocalizedString(@"LoginErrorTitle", nil)
         withMessage:NSLocalizedString(errorCode, nil)];
    } else {
        [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate]
         presentAlerWithTitle:NSLocalizedString(@"LoginErrorTitle", nil)
         withMessage:error.localizedDescription];
        
    }
}

- (void)didLoginSuccessfully {
    
    self.loadingView.alpha = 0; 
    [self dismissViewControllerAnimated:YES completion:^{
        UITabBarController *tabBarController = (UITabBarController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
        [tabBarController setSelectedIndex:0];
    }];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.username]) {
        [textField resignFirstResponder];
        [self.password becomeFirstResponder];
        return YES;
    }
    
    if ([textField isEqual:self.password]) {
        [textField resignFirstResponder];
        [self login:textField];
    }
    return YES;
}

- (IBAction)openURL:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.cmonehealth.org"]];
}

- (IBAction)openPrivacyPolicyURL:(id)sender {
    
    [self performSegueWithIdentifier:@"presentEulaIdentifier" sender:nil];
}

@end

@implementation LoginViewController (Keyboard)

- (void)setupKeyboardObservers {
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self
     selector:@selector(observeKeyboard:)
     name:UIKeyboardWillShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self
     selector:@selector(observeKeyboard:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void)removeKeyboardObservers {
    
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self
     name:UIKeyboardWillShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void)observeKeyboard:(NSNotification *)notification {
    
    NSValue *keyboardRectValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [keyboardRectValue CGRectValue];
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    self.bottomLayoutConstraint.constant = CGRectGetMaxY(screenBound) - keyboardRect.origin.y;
}

@end
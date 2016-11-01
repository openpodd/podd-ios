//
//  RegistrationFormTableViewController.m
//  poddreport
//
//  Created by polawat phetra on 2/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "RegistrationFormTableViewController.h"
#import "RegisterCommand.h"
#import "ConfigurationCommand.h"
#import "ReportAppDelegate.h"
#import "ConfigurationManager.h"

@interface RegistrationFormTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *identificationNumberField;
@property (weak, nonatomic) IBOutlet UITextField *mobileNumberField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@end

@implementation RegistrationFormTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

#pragma mark - Navigation

- (IBAction)submit:(id)sender {
    RegisterCommand *command = [[RegisterCommand alloc] initWithConfiguration:[ConfigurationManager sharedConfiguration]];
    
    [self showActivityIndicator];
    
    [command setFirstName:[self.firstNameField text]];
    [command setLastName:[self.lastNameField text]];
    [command setIdentificationNumber:[self.identificationNumberField text]];
    [command setMobileNumber:[self.mobileNumberField text]];
    [command setEmail:[self.emailField text]];
    [command setInvitationCode:self.invitationCode];

    [command setCompletionBlock:^(NSDictionary *params) {
        ConfigurationCommand *configurationCommand = [[ConfigurationCommand alloc] initWithConfiguration:[ConfigurationManager sharedConfiguration]];
        configurationCommand.data = [ConfigurationManager sharedConfiguration].deviceInformation;
        [configurationCommand setCompletionBlock:^(NSDictionary *params){
            [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate] setupAWS];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self removeActivityIndicator];
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }];
        [configurationCommand start];
    }];
    [command setFailedBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeActivityIndicator];
            NSString *errorCode = [NSString stringWithFormat:@"%tu", error.code];
            NSArray *errorMsgs = error.userInfo[@"errorMsgs"];
            NSString *errorString = [errorMsgs componentsJoinedByString:@"\n"];
            [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate]
                presentAlerWithTitle:NSLocalizedString(@"QuestionValidationErrorTitle", nil)
                withMessage:errorString];
            NSLog(@"%@", errorCode);
        });
    }];
    [command start];
}

- (void)showActivityIndicator {
    UIView *view = self.navigationController.view;
    UIActivityIndicatorView  *av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    av.frame = view.bounds;
    av.tag  = 1;
    [view addSubview:av];
    [av startAnimating];
}

- (void)removeActivityIndicator {
    UIActivityIndicatorView *tmpimg = (UIActivityIndicatorView *)[self.navigationController.view viewWithTag:1];
    [tmpimg removeFromSuperview];
}

/*

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

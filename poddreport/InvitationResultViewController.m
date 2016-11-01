//
//  InvitationResultViewController.m
//  poddreport
//
//  Created by polawat phetra on 2/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "InvitationResultViewController.h"
#import "CheckInvitationCodeCommand.h"
#import "RegistrationFormTableViewController.h"
#import "ConfigurationManager.h"

@interface InvitationResultViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) NSString *authorityName;


@end

@implementation InvitationResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self waitForResult];
    
    CheckInvitationCodeCommand *command = [[CheckInvitationCodeCommand alloc] initWithConfiguration:[ConfigurationManager sharedConfiguration]];
    [command setInvitationCode:self.invitationCode];
    [command setCompletionBlock:^(NSDictionary *params) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self resultComplete:params[@"authorityName"]];
            });
        }];
    [command setFailedBlock:^(NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *errorCode = [NSString stringWithFormat:@"%tu", error.code];
            [self resultFailure: NSLocalizedString(errorCode, nil)];
        });
    }];
    
    [command start];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - hide & show

- (void) resultComplete:(NSString *)authorityName {
    [self.resultLabel setHidden:NO];
    self.authorityName = authorityName;
    [self.resultLabel setText:[NSString stringWithFormat:@"พื้นที่ของคุณคือ: %@", authorityName]];
    
    [self.nextButton setEnabled:YES];
    [self.nextButton setTintColor:[UIColor whiteColor]];
    
    [self hideProgressIndicator];
}

- (void) resultFailure:(NSString *)errorDescription {
    [self.resultLabel setHidden:NO];
    [self.resultLabel setText:errorDescription];
    
    [self hideProgressIndicator];
}

- (void) waitForResult {
    [self.resultLabel setHidden:YES];

    [self.nextButton setEnabled:NO];
    [self.nextButton setTintColor:[UIColor clearColor]];
    
    [self showProgressIndicator];
}

- (void) showProgressIndicator {
    if (self.activityView == Nil) {
        self.activityView = [[UIActivityIndicatorView alloc]
                                                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        self.activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        
        self.activityView.frame = CGRectMake(10.0, 0.0, 40.0, 40.0);
        self.activityView.color = [UIColor blackColor];
        self.activityView.center = self.view.center;
        
        [self.view addSubview:self.activityView];
    }

    [self.activityView startAnimating];
    [self.activityView setHidden:NO];
}

- (void) hideProgressIndicator {
    [self.activityView stopAnimating];
    [self.activityView setHidden:YES];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    RegistrationFormTableViewController *controller = [segue destinationViewController];
    controller.invitationCode = self.invitationCode;
    controller.authorityName = self.authorityName;
}

@end

//
//  InvitationViewController.m
//  poddreport
//
//  Created by polawat phetra on 2/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "InvitationViewController.h"
#import "InvitationResultViewController.h"

@interface InvitationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *invitationCodeTextField;

@end

@implementation InvitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self navigationController] setNavigationBarHidden:NO];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *code = [self.invitationCodeTextField text];
    InvitationResultViewController *controller = [segue destinationViewController];
    controller.invitationCode = code;
}

@end

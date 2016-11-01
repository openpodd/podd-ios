//
//  SettingTableViewController.m
//  poddreport
//
//  Created by polawat phetra on 2/25/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "SettingTableViewController.h"
#import "ConfigurationManager.h"
#import "ReportAppDelegate.h"
#import "LogoutCommand.h"

@interface SettingTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@end

@implementation SettingTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    ConfigurationManager *config = [ConfigurationManager sharedConfiguration];
    NSDictionary *user = config.authenticationUser;
    self.usernameLabel.text = user[@"username"];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", user[@"firstName"] ?: @"", user[@"lastName"] ?: @""];
    self.versionLabel.text = [NSString stringWithFormat:@"%@.%@", self.current_version, self.current_build_version];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)logout:(id)sender {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"LogoutConfirmationTitle", nil)
                                          message:NSLocalizedString(@"LogoutConfirmationMessage", nil)
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction
                                actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                style:UIAlertActionStyleCancel
                                handler:nil]];
    
    
    [alertController addAction:[UIAlertAction
                                actionWithTitle:NSLocalizedString(@"Logout", nil)
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction * _Nonnull action) {
                                    [self performLogout];
                                }]];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

- (void)performLogout {
    
    NSManagedObjectContext *managedObjectContext = [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    LogoutCommand *command = [[LogoutCommand alloc]
                              initWithManagedObjectContext:managedObjectContext
                              configuration:[ConfigurationManager sharedConfiguration]];
    
    [command setCompletionBlock:^(NSDictionary *params) {
        [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate] checkServiceAuthurization];
        [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate] reportSyncCommandDidChangeData];
    }];
    
    [command start];
}

#pragma mark - Version summary

- (NSString *)current_version {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

- (NSString *)current_build_version {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}


@end

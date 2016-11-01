//
//  ViewController.m
//  ReportUI
//
//  Created by Opendream-iOS on 1/25/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ViewController.h"
#import "ReportAppDelegate.h"
#import "LogoutCommand.h"


#import "ConfigurationManager.h"
#import "ReportNavigationController.h"

@interface ViewController ()
@property (weak, nonatomic, nullable) IBOutlet UIButton *createButton;
@property (weak, nonatomic, nullable) IBOutlet UIView *noResultsView;
@end

@implementation ViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    UIImage *logo = [UIImage imageNamed:@"nav-logo"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logo];
    
    
    [self setupAppearance];
    [self reloadNoResultsView];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadNoResultsView)
     name:@"ReportSyncCommandDidChangeData"
     object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self reloadNoResultsView];
}

- (void)reloadNoResultsView {
    
    NSManagedObjectContext *managedObjectContext = [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Report"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:NO]];
    NSUInteger itemCount = [managedObjectContext countForFetchRequest:request error:nil];
    self.noResultsView.hidden = itemCount > 0;
}

- (void)setupAppearance {
    
    self.createButton.layer.cornerRadius = 24;
}

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
                                actionWithTitle:NSLocalizedString(@"Sync", nil) 
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * _Nonnull action) {
                                    [self performSync];
                                }]];
    
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

- (void)performSync {
    
    [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate] startReportSync];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ReportSegueIdentifier"]) {
        ReportNavigationController *reportNavigationController = (ReportNavigationController *)segue.destinationViewController;
        if (sender) {
            [reportNavigationController setTesting:YES];
        }  
    }
}

@end

@implementation ViewController (ReportAction)

- (IBAction)report:(id)sender {
    
    NSUInteger adminAreaCount = [[[ConfigurationManager sharedConfiguration] administrationAreas] count];
    if (adminAreaCount == 0) {
        UIAlertController *alertController = [UIAlertController 
                                              alertControllerWithTitle:NSLocalizedString(@"NoAdministrationAreaData", nil)
                                              message:NSLocalizedString(@"NoAdministrationAreaDataDescription", nil)
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction 
                                    actionWithTitle:NSLocalizedString(@"OK", nil) 
                                    style:UIAlertActionStyleDefault 
                                    handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController 
                                          alertControllerWithTitle:NSLocalizedString(@"ReportActionTitle", nil)
                                          message:NSLocalizedString(@"ReportActionSubtitle", nil)
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction 
                                actionWithTitle:NSLocalizedString(@"AddReport", nil) 
                                style:UIAlertActionStyleDefault 
                                handler:^(UIAlertAction * _Nonnull action) {
                                    [self performSegueWithIdentifier:@"ReportSegueIdentifier" sender:nil];
                                }]];
    
    [alertController addAction:[UIAlertAction 
                                actionWithTitle:NSLocalizedString(@"ReportTest", nil) 
                                style:UIAlertActionStyleDefault 
                                handler:^(UIAlertAction * _Nonnull action) {
                                    [self performSegueWithIdentifier:@"ReportSegueIdentifier" sender:@"testFlag"];
                                }]];
    
    [alertController addAction:[UIAlertAction 
                                actionWithTitle:NSLocalizedString(@"Cancel", nil) 
                                style:UIAlertActionStyleCancel
                                handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
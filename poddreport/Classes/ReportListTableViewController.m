//
//  ReportListTableViewController.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/28/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportListTableViewController.h"
#import "ReportTableViewCell.h"
#import "ReportAppDelegate.h"
#import "ConfigurationManager.h"
#import "ReportType.h"
#import "ReportNavigationController.h"

@interface ReportListTableViewController () <ReportTableViewCellDelegate> {
    NSDateFormatter *_dateFormaater;
}
@property (strong, nonatomic, nullable) NSArray<ReportManagedObject *> *items;
@property (weak, nonatomic, nullable) NSManagedObjectContext *managedObjectContext;
- (ReportType * _Nonnull)reportTypeFromUid:(int)uid;
@end

@interface ReportListTableViewController (ViewCellHelper)
- (NSString * _Nullable)submitStatusString:(ReportSubmitStatus)status;
@end

@interface ReportListTableViewController (Followable)
- (void)followUpReportGuid:(NSString * _Nonnull)reportGuid;
- (BOOL)canFollowUpReportSinceCreatedDate:(NSDate * _Nonnull)createdDate referenceDate:(NSDate * _Nonnull)referenceDate followDays:(int)followDays;
@end

@implementation ReportListTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 90;
    
    _items = [NSArray new];
    
    self.managedObjectContext = [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didChangeData:)
     name:@"ReportSyncCommandDidChangeData"
     object:nil];
    
    _dateFormaater = [[NSDateFormatter alloc] init];
    [_dateFormaater setLocale:[NSLocale localeWithLocaleIdentifier:@"th"]];
    [_dateFormaater setDateFormat:@"dd MMM yyyy, HH:mm น."];
}

- (void)didChangeData:(NSNotification *)notification {
    
    [self fetch];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self fetch];
}

- (void)fetch {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Report"];
        request.sortDescriptors = @[
                                    [NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:NO]
                                    ,[NSSortDescriptor sortDescriptorWithKey:@"followDate" ascending:NO]
                                    ];
        NSArray *items = [self.managedObjectContext executeFetchRequest:request error:NULL];
        self.items = items;
        [self.tableView reloadData];
    });
}

#pragma makr - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ReportSegueIdentifier"]) {
        ReportNavigationController *reportNavigationController = (ReportNavigationController *)segue.destinationViewController;
        
        if (sender) {
            ReportManagedObject *report = [self findLastestReportWithParentReportGuid:sender];
            ReportType *reportType = [self reportTypeFromUid:report.reportTypeId.intValue];
            NSData *data = [report.formData dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *formData = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
            
            [reportNavigationController
             followUpReportType:reportType
             defaultData:formData
             parentReportGuid:sender
             incidentDate:report.incidentDate
             andAdministrationAreaId:report.administrationArea.intValue];
        }
    }
}

- (ReportManagedObject * _Nullable)findLastestReportWithParentReportGuid:(NSString * _Nonnull)parentReportGuid {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:
                              @"(guid == %@) OR (parentReportGuid == %@)"
                              ,parentReportGuid
                              ,parentReportGuid];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"followDate" ascending:NO]];
    NSArray *results = [self.managedObjectContext
                        executeFetchRequest:fetchRequest
                        error:nil];
    ReportManagedObject *report = results.firstObject;
    return report;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ReportTableViewCell *cell;
    
    static NSString * const cellIdentifier = @"ReportCellIdentifier";
    static NSString * const followUpCellIdentifier = @"ReportFollowUpCellIdentifier";
    
    ReportManagedObject *report = [self.items objectAtIndex:indexPath.row];
    ReportType *reportType = [self reportTypeFromUid:report.reportTypeId.intValue];
    
    BOOL isParent = (report.parentReportGuid == nil);
    if (isParent) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.typeLabel.text = NSLocalizedString(reportType.name, nil);
        cell.dateLabel.text = [_dateFormaater stringFromDate:report.createdDate];
        cell.reportGuid = report.guid;
        cell.delegate = self;
        cell.statusLabel.text = [NSString stringWithFormat:
                                 NSLocalizedString(@"SubmitStatus %@", nil)
                                 ,[self submitStatusString:report.submitStatus.intValue]];
        
        if (ReportSubmitStatusDone == report.submitStatus.intValue) {
            cell.statusIconImageView.image = [UIImage imageNamed:@"ic-checked-small"];
            cell.statusLabel.textColor = [UIColor colorWithRed:0.2078 green:0.7373 blue:0.0078 alpha:1.0];
        } else {
            cell.statusIconImageView.image = [UIImage imageNamed:@"ic-time-small"];
            cell.statusLabel.textColor = [UIColor colorWithRed:0.5254 green:0.5254 blue:0.5254 alpha:1.0];
        }
            
        if (reportType.followable) {
            BOOL canFollowUp = [self canFollowUpReportSinceCreatedDate:report.createdDate
                                referenceDate:[NSDate date]
                                followDays:reportType.followDays];
            cell.followButton.hidden = !canFollowUp;
        } else {
            cell.followButton.hidden = YES;
        }
        
        if (report.testing.boolValue) {
            cell.iconImageView.image = [UIImage imageNamed:@"ic-report-type-test"];
        } else if (report.reportTypeId.intValue == ReportTypeNormal) {
            cell.iconImageView.image = [UIImage imageNamed:@"ic-report-type-normal"];
        } else {
            cell.iconImageView.image = [UIImage imageNamed:@"ic-report-type-red"];
        }
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:followUpCellIdentifier forIndexPath:indexPath];
        cell.dateLabel.text = [_dateFormaater stringFromDate:report.followDate];
        cell.typeLabel.text = [NSString stringWithFormat:
                                NSLocalizedString(@"SubmitStatus %@", nil)
                                ,[self submitStatusString:report.submitStatus.intValue]];
        cell.delegate = nil;
    }
    
    return cell;
}

- (ReportType * _Nonnull)reportTypeFromUid:(int)uid {
    
    NSArray<ReportType *> *reportTypes = [[ConfigurationManager sharedConfiguration] reportTypes];
    for (ReportType *reportType in reportTypes) {
        if (uid == reportType.uid) {
            return reportType;
        }
    }
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ReportManagedObject *report = [self.items objectAtIndex:indexPath.row];
    BOOL isReportTypeNormal = report.reportTypeId.intValue == ReportTypeNormal;
    if (isReportTypeNormal) {
        return nil;
        
    } else {
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ReportManagedObject *report = [self.items objectAtIndex:indexPath.row];
    [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate] presentReportFormWithReportIdentifier:report.guid];
}

- (void)reportTableViewCellDidTapFollowButtonWithReportGuid:(NSString *)reportGuid {
    
    [self followUpReportGuid:reportGuid];
}

@end

@implementation ReportListTableViewController (ViewCellHelper)

- (NSString * _Nullable)submitStatusString:(ReportSubmitStatus)status {
    
    switch (status) {
        case ReportSubmitStatusWaiting:
            return NSLocalizedString(@"Waiting", nil);
        case ReportSubmitStatusFailed:
            return NSLocalizedString(@"Failed", nil);
        case ReportSubmitStatusDone:
            return NSLocalizedString(@"Sent", nil);
    }
}

@end

@implementation ReportListTableViewController (Followable)

- (void)followUpReportGuid:(NSString * _Nonnull)reportGuid {
    
    UIAlertController *alertController;
    alertController = [UIAlertController 
                       alertControllerWithTitle:NSLocalizedString(@"FollowUpConfirmTitle", nil)
                       message:NSLocalizedString(@"FollowUpConfirmSubtitle", nil)
                       preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController
     addAction:[UIAlertAction
                actionWithTitle:NSLocalizedString(@"FollowUpConfirmButton", nil)
                style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * _Nonnull action) {
                    
        [self performSegueWithIdentifier:@"ReportSegueIdentifier" sender:reportGuid];
    }]];
    
    [alertController
     addAction:[UIAlertAction
                actionWithTitle:NSLocalizedString(@"Cancel", nil)
                style:UIAlertActionStyleCancel
                handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)canFollowUpReportSinceCreatedDate:(NSDate * _Nonnull)createdDate referenceDate:(NSDate * _Nonnull)referenceDate followDays:(int)followDays {
    
    NSTimeInterval interval = [referenceDate timeIntervalSinceDate:createdDate];
    NSTimeInterval days = followDays * 24 * 60 * 60;
    if (fabs(interval) >= days) {
        return NO;
    } else {
        return YES;
    }
}

@end
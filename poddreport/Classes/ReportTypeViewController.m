//
//  ReportTypeViewController.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/20/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportTypeViewController.h"
#import "ReportNavigationController.h"
#import "LoginCommand.h"
#import "ConfigurationCommand.h"
#import "ConfigurationManager.h"
#import "ReportType.h"
#import "ReportTypeSyncCommand.h"
#import "ReportAppDelegate.h"

@interface ReportTypeViewController () <UITableViewDataSource, UITableViewDelegate>

// IBOutlet
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noResultsView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

// DataSource
@property (strong, nonatomic) NSArray<ReportType *> *reportTypes;

@end

@interface ReportTypeViewController (Mapping)
- (UIImage *)imageForReportTypeName:(NSString *)name;
@end

@implementation ReportTypeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self reloadData];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    self.title = self.navigationController.isTesting ? NSLocalizedString(@"TestReport", nil) : NSLocalizedString(@"Report", nil);
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    self.refreshControl = refreshControl;
}

- (void)refresh {
    
    [self.refreshControl beginRefreshing];
    [self requestUpdate];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.refreshControl) {
            [self.refreshControl endRefreshing];
        }
    });
}

- (void)requestUpdate {
    
    ReportTypeSyncCommand *command = [[ReportTypeSyncCommand alloc] initWithConfiguration:
                            [ConfigurationManager sharedConfiguration]];
    [command setCompletionBlock:^(id object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
            if (self.refreshControl) {
                [self.refreshControl endRefreshing];
            }
        });
    }];
    [command start];
}

- (void)reloadData {
    
    self.reportTypes = [[ConfigurationManager sharedConfiguration] reportTypes];
    [self.tableView reloadData];
    
    self.noResultsView.alpha = self.reportTypes.count > 0 ? 0 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.reportTypes.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * const cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    ReportType *item = [self.reportTypes objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
    cell.textLabel.font = [UIFont fontWithName:@"SukhumvitSet-Text" size:17];
    cell.detailTextLabel.text = [@(item.version) stringValue];
    cell.detailTextLabel.font = [UIFont fontWithName:@"SukhumvitSet-Light" size:17];
    cell.imageView.image = [self imageForReportTypeName:item.name];
    cell.imageView.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ReportType *item = [self.reportTypes objectAtIndex:indexPath.row];
    [self.navigationController setReportType:item];
    
    if (item.uid == ReportTypeNormal) {
        [self.navigationController submit];
        
    } else {
        [self performSegueWithIdentifier:@"ImagePickerSegue" sender:item];
    }
}

@end


@implementation ReportTypeViewController (Mapping)

- (UIImage *)imageForReportTypeName:(NSString *)name {
    
    NSString *imageName = @"etc";
    NSDictionary *reportType = @{ @"ปกติ": @"normal"
                                  ,@"สัตว์ป่วย/ตาย": @"animal-sick-death"
                                  ,@"สัตว์กัด": @"animal-bite"
                                  ,@"โรคเกี่ยวกับสัตว์และคน": @"human"
                                  ,@"อาหารปลอดภัย": @"food"
                                  ,@"คุ้มครองผู้บริโภค": @"human2"
                                  ,@"สิ่งแวดล้อม": @"environment"
                                  ,@"ภัยธรรมชาติ": @"disaster"
                                 };
    if ([reportType valueForKey:name]) {
        imageName = reportType[name];
    }
    return [UIImage imageNamed:imageName];
}

@end
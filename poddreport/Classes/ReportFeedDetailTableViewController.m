//
//  ReportFeedDetailTableViewController.m
//  poddreport
//
//  Created by Opendream-iOS on 2/26/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportFeedDetailTableViewController.h"
#import "ReportFeedItem.h"

static NSString * DisplayEmptyStringIfNeeds(NSString *string) {
    
    if (!string || string.length == 0) {
        return NSLocalizedString(@"-", nil);
    } else {
        return string;
    }
}

@interface ReportFeedDetailTableViewController () {
    NSDateFormatter *_dateFormatter;
    NSDateFormatter *_incidentDateFormatter;
}
@property (weak, nonatomic, nullable) IBOutlet UILabel *reportTypeLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *reportDateLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *incidentDateLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *administrationAreaLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *createdByLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *telephoneLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *formDescriptionLabel;
@property (weak, nonatomic, nullable) IBOutlet UIImageView *reportImageView;
@end

@implementation ReportFeedDetailTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    _incidentDateFormatter = [[NSDateFormatter alloc] init];
    [_incidentDateFormatter setDateFormat:@"dd MMM yyyy"];
    [_incidentDateFormatter setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierBuddhist]];
    [_incidentDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"th"]];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"dd MMM yyyy HH:mm a"];
    [_dateFormatter setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierBuddhist]];
    [_dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"th"]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.title = self.item.reportTypeName;
    self.reportTypeLabel.text = DisplayEmptyStringIfNeeds(self.item.reportTypeName);
    self.administrationAreaLabel.text = DisplayEmptyStringIfNeeds(self.item.administrationAreaAddress);
    self.createdByLabel.text = DisplayEmptyStringIfNeeds(self.item.createdByName);
    self.telephoneLabel.text = DisplayEmptyStringIfNeeds(self.item.createdByTelephone);
    
    self.reportDateLabel.text = DisplayEmptyStringIfNeeds([_dateFormatter stringFromDate:self.item.date]);
    self.incidentDateLabel.text = DisplayEmptyStringIfNeeds([_incidentDateFormatter stringFromDate:self.item.incidentDate]);
    self.formDescriptionLabel.attributedText = self.item.reportDescriptionAttributedString;
    
    if (self.item.firstImageThumbnail && self.item.firstImageThumbnail.length > 0) {
        [self loadImageData];
    }
}

- (void)loadImageData {
    
    NSURL *imageUrl = [NSURL URLWithString:self.item.firstImageThumbnail];
    [[[NSURLSession sharedSession] dataTaskWithURL:imageUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.1f animations:^{
                self.reportImageView.image = image;
                [self.tableView reloadData];
            }];
        });
    }] resume];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (self.item.firstImageThumbnail == nil || self.item.firstImageThumbnail.length == 0) {
            return 0;
        }
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0;
    } else {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}

@end

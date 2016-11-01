//
//  ReportTableViewCell.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/28/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportTableViewCell.h"

@implementation ReportTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.followButton.layer.cornerRadius = 5;
    self.shadowView.layer.cornerRadius = 9;
    self.shadowView.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2].CGColor;
    self.shadowView.layer.shadowOffset = CGSizeMake(0, 1);
    self.shadowView.layer.shadowOpacity = 1;
    self.shadowView.layer.shadowRadius = 1;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    self.typeLabel.text = nil;
    self.dateLabel.text = nil;
    self.statusLabel.text = nil;
    self.followButton.hidden = YES;
    self.reportGuid = nil;
    self.delegate = nil;
}

- (IBAction)follow:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(reportTableViewCellDidTapFollowButtonWithReportGuid:)]) {
        [self.delegate reportTableViewCellDidTapFollowButtonWithReportGuid:self.reportGuid];
    }
}

@end

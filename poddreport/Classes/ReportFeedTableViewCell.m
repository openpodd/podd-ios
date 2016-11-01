//
//  ReportFeedTableViewCell.m
//  poddreport
//
//  Created by Opendream-iOS on 2/23/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportFeedTableViewCell.h"

@implementation ReportFeedTableViewCell

- (void)prepareForReuse {
    
    [super prepareForReuse];
    self.displayNameLabel.text = nil;
    self.reportTypeLabel.text = nil;
    self.reportDescriptionLabel.text = nil;
    self.reportLocationLabel.text = nil;
    self.reportDateLabel.text = nil;
    self.reportTypeIconImageView.image = nil;
    self.reportImageView.image = nil;
    self.avatarImageView.image = nil;
    self.reportImageHeightLayoutConstraint.constant = 0;
}

@end

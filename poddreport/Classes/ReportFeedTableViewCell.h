//
//  ReportFeedTableViewCell.h
//  poddreport
//
//  Created by Opendream-iOS on 2/23/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportFeedTableViewCell : UITableViewCell

@property (weak, nonatomic, nullable) IBOutlet UIView *wrapperView;
@property (weak, nonatomic, nullable) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *reportTypeLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *reportDescriptionLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *reportLocationLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *reportDateLabel;
@property (weak, nonatomic, nullable) IBOutlet UIImageView *reportTypeIconImageView;
@property (weak, nonatomic, nullable) IBOutlet UIImageView *reportImageView;
@property (weak, nonatomic, nullable) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic, nullable) IBOutlet NSLayoutConstraint *reportImageHeightLayoutConstraint;

@end

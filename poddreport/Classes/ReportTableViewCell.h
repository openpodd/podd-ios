//
//  ReportTableViewCell.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/28/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

@import UIKit;

@protocol ReportTableViewCellDelegate <NSObject>
- (void)reportTableViewCellDidTapFollowButtonWithReportGuid:(NSString * _Nonnull)reportGuid;
@end

@interface ReportTableViewCell : UITableViewCell

@property (unsafe_unretained, nullable) id <ReportTableViewCellDelegate> delegate;
@property (copy, nonatomic, nullable) NSString *reportGuid;
@property (strong, nonatomic, nonnull) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic, nonnull) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic, nonnull) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic, nonnull) IBOutlet UIButton *followButton;
@property (strong, nonatomic, nonnull) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic, nonnull) IBOutlet UIImageView *statusIconImageView;
@property (strong, nonatomic, nonnull) IBOutlet UIView *shadowView;
@end

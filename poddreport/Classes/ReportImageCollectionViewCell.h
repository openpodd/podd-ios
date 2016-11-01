//
//  ReportImageCollectionViewCell.h
//  poddreport
//
//  Created by Opendream-iOS on 2/1/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportImageCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic, nullable) IBOutlet UIImageView *imageView;
@property (strong, nonatomic, nullable) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic, nullable) IBOutlet UILabel *noteLabel;
@end

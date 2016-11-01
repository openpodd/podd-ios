//
//  FormShadowView.m
//  poddreport
//
//  Created by Opendream-iOS on 2/18/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "FormShadowView.h"

@implementation FormShadowView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.clipsToBounds = NO;
    self.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 2;
}

@end

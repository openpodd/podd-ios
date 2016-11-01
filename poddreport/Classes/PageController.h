//
//  PageController.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/25/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportBaseViewController.h"

@class PageContext;

@interface PageController : ReportBaseViewController
@property (strong, nonatomic, nullable) PageContext *pageContext;
@property (weak, nonatomic, nullable) IBOutlet NSLayoutConstraint *reportStatusViewHeightConstraint;
@end
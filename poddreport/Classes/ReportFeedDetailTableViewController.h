//
//  ReportFeedDetailTableViewController.h
//  poddreport
//
//  Created by Opendream-iOS on 2/26/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

@import UIKit;

@class ReportFeedItem;

@interface ReportFeedDetailTableViewController : UITableViewController
@property (weak, nonatomic, nullable) ReportFeedItem *item;
@end

//
//  ReportListTableViewControllerTests.m
//  poddreport
//
//  Created by Opendream-iOS on 2/17/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReportListTableViewController.h"

@interface ReportListTableViewControllerTests : XCTestCase

@end

@interface ReportListTableViewController (FollowUpTests)
- (BOOL)canFollowUpReportSinceCreatedDate:(NSDate * _Nonnull)createdDate referenceDate:(NSDate * _Nonnull)referenceDate followDays:(int)followDays;
@end

@implementation ReportListTableViewControllerTests

- (void)testShouldDisplayFollowUpButtonSinceDate {
    
    ReportListTableViewController *controller = [ReportListTableViewController new];
    
    int followUpDays = 21;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    
    NSDate *referenceDate = [dateFormatter dateFromString:@"2016/01/01 07:00"];
    NSDate *date = [dateFormatter dateFromString:@"2016/01/07 07:00"];
    XCTAssertTrue([controller canFollowUpReportSinceCreatedDate:date referenceDate:referenceDate followDays:followUpDays]);
    
    date = [dateFormatter dateFromString:@"2016/01/21 07:00"];
    XCTAssertTrue([controller canFollowUpReportSinceCreatedDate:date referenceDate:referenceDate followDays:followUpDays]);
    
    date = [dateFormatter dateFromString:@"2016/01/21 07:01"];
    XCTAssertTrue([controller canFollowUpReportSinceCreatedDate:date referenceDate:referenceDate followDays:followUpDays]);
    
    date = [dateFormatter dateFromString:@"2016/01/21 06:59"];
    XCTAssertTrue([controller canFollowUpReportSinceCreatedDate:date referenceDate:referenceDate followDays:followUpDays]);
    
    date = [dateFormatter dateFromString:@"2016/01/22 07:00"];
    XCTAssertFalse([controller canFollowUpReportSinceCreatedDate:date referenceDate:referenceDate followDays:followUpDays]);
    
    date = [dateFormatter dateFromString:@"2016/01/22 07:01"];
    XCTAssertFalse([controller canFollowUpReportSinceCreatedDate:date referenceDate:referenceDate followDays:followUpDays]);
}

@end

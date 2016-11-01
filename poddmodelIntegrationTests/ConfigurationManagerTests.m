//
//  ConfigurationManagerTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/19/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ConfigurationManager.h"
#import "ReportType.h"

@interface ConfigurationManagerTests : XCTestCase {
    NSDictionary *configurationResponse;
}
@end


@implementation ConfigurationManagerTests

- (void)setUp {
    
    [super setUp];
    configurationResponse = @{
                              @"awsAccessKey":@"aaa",
                              @"fullName": @"bbb",
                              @"awsSecretKey": @"ccc",
                              @"administrationAreas" : @[@"a", @"b"], 
                              @"reportTypes": @[@{@"name":@"b", @"weight":@1}, @{@"name":@"c", @"weight":@2}, @{@"name":@"d", @"weight":@3}]
                              };
}
- (void)testSingletonShouldExist {
    
    XCTAssertNotNil(ConfigurationManager.sharedConfiguration);
}

- (void)testShouldCustomEndpoint {
    
    NSDictionary *configurations = @{@"endpoint":@"http://www.example.com"};
    ConfigurationManager *manager = [[ConfigurationManager alloc] initWithConfigurations:configurations];
    XCTAssertNotNil(manager);
    
    [manager setEndpoint:@"xxx"];
    XCTAssertTrue([@"xxx" isEqualToString:[manager endpoint]]);
    
    [manager setEndpoint:nil];
    XCTAssertTrue([configurations[@"endpoint"] isEqualToString:[manager endpoint]]);
}

- (void)testShouldSaveConfigurationResponse {
    
    ConfigurationManager *manager = [[ConfigurationManager alloc] init];
    BOOL success = [manager setConfigurationResponse:configurationResponse];
    XCTAssertTrue(success);
    
    XCTAssertTrue([configurationResponse[@"awsAccessKey"] isEqualToString:[manager AWSAccessKey]]);
    XCTAssertTrue([configurationResponse[@"awsSecretKey"] isEqualToString:[manager AWSSecretKey]]);
    
    XCTAssertTrue(2 == manager.administrationAreas.count);
}

- (void)testShouldRemoveAllReportTypes {
    
    ConfigurationManager *manager = [[ConfigurationManager alloc] init];
    BOOL success = [manager setConfigurationResponse:configurationResponse];
    XCTAssertTrue(success);
    
    [manager removeAllReportTypes];
    XCTAssertTrue(0 == manager.reportTypes.count);
}

- (void)testShouldSaveSortedReportTypes {
    
    NSArray<ReportType *> *reportTypes, *sortedReportTypes;
    ConfigurationManager *manager = [[ConfigurationManager alloc] init];
    
    // Ordered Array
    ReportType *rt1 = [ReportType newWithData:@{@"id":@1, @"weight" : @0}];
    ReportType *rt2 = [ReportType newWithData:@{@"id":@2, @"weight" : @1}];
    ReportType *rt3 = [ReportType newWithData:@{@"id":@3, @"weight" : @2}];
    reportTypes = @[rt1, rt2, rt3];
    [manager setReportTypes:reportTypes];
    
    sortedReportTypes = manager.reportTypes;
    XCTAssertTrue([sortedReportTypes[0] weight] < [sortedReportTypes[1] weight]);
    XCTAssertTrue([sortedReportTypes[1] weight] < [sortedReportTypes[2] weight]);
    
    // Unordered Array
    rt1 = [ReportType newWithData:@{@"id":@1, @"weight" : @1}];
    rt2 = [ReportType newWithData:@{@"id":@2, @"weight" : @3}];
    rt3 = [ReportType newWithData:@{@"id":@3, @"weight" : @2}];
    reportTypes = @[rt1, rt2, rt3];
    [manager setReportTypes:reportTypes];
    
    sortedReportTypes = manager.reportTypes;
    XCTAssertTrue([sortedReportTypes[0] weight] < [sortedReportTypes[1] weight]);
    XCTAssertTrue([sortedReportTypes[1] weight] < [sortedReportTypes[2] weight]);
}

@end

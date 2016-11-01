//
//  ReportTypeSyncCommandTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/21/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReportTypeSyncCommand.h"
#import "ReportType.h"
#import "ConfigurationManager.h"

@interface ReportTypeSyncCommandTests : XCTestCase {
    ReportType *rt1, *rt2, *rt3, *rt3new, *rt3newnew, *rt4, *rt4new;
    NSDictionary *results;
    ConfigurationManager *configuration;
}

@end

@interface ReportTypeSyncCommand (Merge)
+ (NSDictionary * _Nonnull)merge:(NSArray<ReportType *> * _Nonnull)reportTypesA with:(NSArray<ReportType *> * _Nonnull)reportTypesB;
@end

@implementation ReportTypeSyncCommandTests

- (void)setUp {
    
    [super setUp];
    configuration = [[ConfigurationManager alloc] init];
    [configuration setAuthenticationToken:@"49f7fd79aee7d16ab186a5869c0509399557d497"];
    
    rt1 = [ReportType newWithData:@{@"id":@1}];
    rt2 = [ReportType newWithData:@{@"id":@2}];
    rt3 = [ReportType newWithData:@{@"id":@3, @"version":@10, @"name": @"aa", @"followable": @NO}];
    rt3new = [ReportType newWithData:@{@"id":@3, @"version":@11, @"name": @"aab", @"followable": @YES}];
    rt3newnew = [ReportType newWithData:@{@"id":@3, @"version":@12}];
    rt4 = [ReportType newWithData:@{@"id":@4, @"version":@11}];
    rt4new = [ReportType newWithData:@{@"id":@4, @"version":@12}];
}

- (void)tearDown {
    
    rt1 = nil;
    rt2 = nil;
    rt3 = nil;
    rt3new = nil;
    results = nil;
    [configuration removeAllReportTypes];
    [super tearDown];
}

- (void)testMergeShouldInsertNewData {
    
    results = [ReportTypeSyncCommand merge:@[] with:@[rt1]];
    XCTAssertTrue([results[@"items"] count] == 1);
    XCTAssertTrue([results[@"items"] containsObject:rt1]);
    
    results = [ReportTypeSyncCommand merge:@[rt1] with:@[rt2, rt3]];
    XCTAssertTrue([results[@"items"] count] == 2);
    XCTAssertFalse([results[@"items"] containsObject:rt1]);
    XCTAssertTrue([results[@"items"] containsObject:rt2]);
    XCTAssertTrue([results[@"items"] containsObject:rt3]);
}

- (void)testMergeShouldDeleteOldData {
    
    results = [ReportTypeSyncCommand merge:@[rt1] with:@[]];
    XCTAssertTrue([results[@"items"] count] == 0);
    XCTAssertTrue([results[@"deletingItems"] count] == 1);
    
    results = [ReportTypeSyncCommand merge:@[rt1] with:@[rt2]];
    XCTAssertTrue([results[@"items"] count] == 1);
    XCTAssertFalse([results[@"items"] containsObject:rt1]);
    XCTAssertTrue([results[@"items"] containsObject:rt2]);
    
    results = [ReportTypeSyncCommand merge:@[rt2] with:@[rt1]];
    XCTAssertTrue([results[@"items"] count] == 1);
    XCTAssertFalse([results[@"items"] containsObject:rt2]);
    XCTAssertTrue([results[@"items"] containsObject:rt1]);
    
    results = [ReportTypeSyncCommand merge:@[rt1] with:@[rt2, rt3]];
    XCTAssertTrue([results[@"items"] count] == 2);
    XCTAssertTrue([results[@"items"] containsObject:rt2]);
    XCTAssertTrue([results[@"items"] containsObject:rt3]);
    XCTAssertFalse([results[@"items"] containsObject:rt1]);
    
    results = [ReportTypeSyncCommand merge:@[rt1, rt2, rt3] with:@[]];
    XCTAssertTrue([results[@"items"] count] == 0);
    XCTAssertTrue([results[@"deletingItems"] count] == 3);
}

- (void)testMergeShouldUpdateNewData {
    
    results = [ReportTypeSyncCommand merge:@[rt3] with:@[rt3new]];
    XCTAssertTrue([results[@"items"] count] == 1);
    XCTAssertTrue([results[@"items"] containsObject:rt3new]);
    ReportType *result = (ReportType *)results[@"items"][0];
    XCTAssertTrue(YES == result.followable);
    XCTAssertTrue(11 == [result version]);
    XCTAssertTrue([@"aab" isEqualToString:result.name]);
    XCTAssertTrue(1 == [results[@"pendingItems"] count]);
    
    results = [ReportTypeSyncCommand merge:@[rt3new] with:@[rt3newnew]];
    XCTAssertTrue([results[@"items"] count] == 1);
    XCTAssertTrue([results[@"items"] containsObject:rt3newnew]);
    result = (ReportType *)results[@"items"][0];
    XCTAssertTrue(12 == [result version]);
    XCTAssertTrue([@"aab" isEqualToString:result.name]);
    XCTAssertTrue(1 == [results[@"pendingItems"] count]);
    
    results = [ReportTypeSyncCommand merge:@[rt3, rt4] with:@[rt3new, rt4new]];
    XCTAssertTrue(2 == [results[@"items"] count]);
    XCTAssertTrue(2 == [results[@"pendingItems"] count]);
}

- (void)testShouldNotDeleteReportTypeNormal {
    
    ReportType *rtNormal = [ReportType newWithData:@{@"id":@(ReportTypeNormal)}];
    results = [ReportTypeSyncCommand merge:@[rtNormal] with:@[]];
    XCTAssertTrue(1 == [results[@"items"] count]);
    XCTAssertTrue(0 == [results[@"pendingItems"] count]);
    XCTAssertTrue(0 == [results[@"deletingItems"] count]);
    
}

- (void)testShouldStartCommand {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"ReportTypeReportTypeSyncCommand"];
    
    ReportTypeSyncCommand *command = [[ReportTypeSyncCommand alloc] initWithConfiguration:configuration];
    [command setCompletionBlock:^(id success) {
        XCTAssertTrue(success);
        [expectation fulfill];
    }];
    
    [command setFailedBlock:^(NSError *error){
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [command start];
    
    [self waitForExpectationsWithTimeout:999 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)testShouldSync_ReportType_2 {
    
    rt2 = [ReportType newWithData:@{ 
                                    @"id": @2
                                    ,@"name": @"สัตวป่วย"
                                    ,@"version": @11
                                    ,@"weight": @0
                                    }];
    [configuration setReportTypes:@[rt2]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"ReportTypeReportTypeSyncCommand"];
    
    ReportTypeSyncCommand *command = [[ReportTypeSyncCommand alloc] initWithConfiguration:configuration];
    [command setCompletionBlock:^(id success) {
        XCTAssertTrue(success);
        [expectation fulfill];
    }]; 
    
    [command setFailedBlock:^(NSError *error){
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [command start];
    
    [self waitForExpectationsWithTimeout:999 handler:^(NSError * _Nullable error) {
        NSArray *reportTypes = configuration.reportTypes;
        NSInteger index = [reportTypes indexOfObject:rt2];
        XCTAssertTrue(index != NSNotFound);
        
        ReportType *rt = [reportTypes objectAtIndex:index];
        XCTAssertTrue([@"สัตว์ป่วย/ตาย" isEqualToString:rt.name]);
        XCTAssertTrue(12 == rt.version);
        XCTAssertNotNil(rt.definition);
        
        XCTAssertNil(error);
    }];
}

@end

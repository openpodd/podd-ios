//
//  ReportUploadCommandTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 2/3/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportSyncCommand.h"

#import "TestCaseWithInMemoryDatastore.h"
#import "Model.h"

#import "ConfigurationManager.h"
#import "podderror.h"

@interface ReportSyncCommandTests : TestCaseWithInMemoryDatastore {
    ConfigurationManager *configuration;
}
@end

@interface ReportSyncCommand (Testing)
- (NSDictionary * _Nullable)serializeReport:(ReportManagedObject *)report;
@end

@implementation ReportSyncCommandTests

- (void)setUp {
    
    [super setUp];
    configuration = [[ConfigurationManager alloc] init];
    [configuration setAuthenticationToken:@"49f7fd79aee7d16ab186a5869c0509399557d497"];
}

- (void)tearDown {
    
    [super tearDown];
}

- (ReportManagedObject *)mockReportWithGuid:(NSString *)guid {
    
    ReportManagedObject *report = [NSEntityDescription 
                                    insertNewObjectForEntityForName:@"Report" 
                                    inManagedObjectContext:self.managedObjectContext];
    report.guid = guid;
    report.reportTypeId = @(2);
    report.administrationArea = @(45);
    report.incidentDate = [NSDate date];
    report.createdDate = [NSDate date];
    report.reportId = @((unsigned long long)[NSDate timeIntervalSinceReferenceDate]);
    return report;
}

- (void)testShouldSerializePayload {
    
    NSDictionary *payload;
    ReportSyncCommand *command = [[ReportSyncCommand alloc]
                                  initWithGuid:nil
                                  managedObjectContext:self.managedObjectContext
                                  configuration:configuration];
    
    ReportManagedObject *report = [NSEntityDescription 
                                   insertNewObjectForEntityForName:@"Report" 
                                   inManagedObjectContext:self.managedObjectContext];
    payload = [command serializeReport:report];
    XCTAssertNil(payload);
    
    report = [NSEntityDescription 
              insertNewObjectForEntityForName:@"Report" 
              inManagedObjectContext:self.managedObjectContext];
    report.guid = @"a";
    payload = [command serializeReport:report];
    XCTAssertNil(payload);
    
    report = [NSEntityDescription 
              insertNewObjectForEntityForName:@"Report" 
              inManagedObjectContext:self.managedObjectContext];
    report.guid = @"a";
    report.reportId = @(0);
    report.administrationArea = @(0);
    report.reportTypeId = @(0);
    payload = [command serializeReport:report];
    XCTAssertNil(payload);
}

- (void)testShouldSucessfullyUpload_With_ReportData {
    
    NSString *guid = [[NSUUID UUID] UUIDString];
    [self mockReportWithGuid:guid];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"ReportUploadCommand"];
    
    ReportSyncCommand *command = [[ReportSyncCommand alloc]
                                  initWithGuid:guid
                                  managedObjectContext:self.managedObjectContext
                                  configuration:configuration];
    [command setCompletionBlock:^{
        [expectation fulfill];
    }];
    
    [[NSOperationQueue mainQueue] addOperation:command];
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    
}

@end
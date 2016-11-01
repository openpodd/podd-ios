//
//  ReportImageSyncCommandTests.m
//  poddreport
//
//  Created by Opendream-iOS on 2/10/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "TestCaseWithInMemoryDatastore.h"
#import "Model.h"

#import "ReportImageSyncCommand.h"
#import "ReportAppDelegate.h"

#import "ConfigurationManager.h"
#import "podderror.h"

@interface ReportImageSyncCommandTests : TestCaseWithInMemoryDatastore {
    ConfigurationManager *configuration;
}

@end

@implementation ReportImageSyncCommandTests

- (void)setUp {
    
    [super setUp];
    configuration = [[ConfigurationManager alloc] init];
    [configuration setAuthenticationToken:@"49f7fd79aee7d16ab186a5869c0509399557d497"];
}

- (void)tearDown {
    
    [super tearDown];
}

- (ReportImageManagedObject *)mockReportImageWithGuid:(NSString *)guid reportGuid:(NSString *)reportGuid {
    
    ReportImageManagedObject *report = [NSEntityDescription 
                                   insertNewObjectForEntityForName:@"ReportImage" 
                                   inManagedObjectContext:self.managedObjectContext];
    report.guid = guid;
    report.reportGuid = reportGuid;
    NSURL *url = [[NSBundle bundleForClass:self.class] URLForResource:@"photo" withExtension:@"jpeg"];
    report.imageUrl = [url path];
    report.thumbnailUrl = [url path];
    return report;
}

- (void)testShouldSucessfullyUpload_With_ReportImageData {
    
    [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate] setupAWS];
    
    NSString *guid = [[NSUUID UUID] UUIDString];
    [self mockReportImageWithGuid:guid reportGuid:@"504db5d0-6036-413a-8ab6-d4fee41565e8"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"ReportImageSyncCommand"];
    
    ReportImageSyncCommand *command = [[ReportImageSyncCommand alloc] initWithGuid:guid managedObjectContext:self.managedObjectContext configuration:configuration];
    [command setCompletionBlock:^{
        [expectation fulfill];
    }];
    
    [[NSOperationQueue mainQueue] addOperation:command];
    
    [self waitForExpectationsWithTimeout:999 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

@end

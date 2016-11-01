//
//  ConfigurationCommandTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/19/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ConfigurationManager.h"
#import "ConfigurationCommand.h"
#import "podderror.h"

#define MAX_RESPONSE_TIME 3

@interface ConfigurationCommandTests : XCTestCase {
    ConfigurationManager *configuration;
}
@end

@implementation ConfigurationCommandTests

- (void)setUp {
    
    [super setUp];
    configuration = [[ConfigurationManager alloc] init];
    [configuration setAuthenticationToken:@"49f7fd79aee7d16ab186a5869c0509399557d497"];
}

- (void)tearDown {
    
    [configuration setEndpoint:nil];
    [configuration setAuthenticationToken:nil];
    configuration = nil;
    [super tearDown];
}

- (void)testShouldNotResponseConfigurationApi {
    
    configuration.endpoint = @"";
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"configurationCommand"];
    
    ConfigurationCommand *command = [[ConfigurationCommand alloc] initWithConfiguration:configuration];
    command.data = configuration.deviceInformation;
    [command setCompletionBlock:^(id success) {
        XCTAssertFalse(success);
        [expectation fulfill];
    }];
    [command setFailedBlock:^(NSError *error) {
        XCTAssertTrue([NSURLErrorDomain isEqualToString:error.domain]);
        [expectation fulfill];
    }];
    
    [command start];
    
    [self waitForExpectationsWithTimeout:MAX_RESPONSE_TIME handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)testShouldFailRegisterDevice {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"configurationCommand"];
    
    ConfigurationCommand *command = [[ConfigurationCommand alloc] initWithConfiguration:configuration];
    command.data = @{};
    [command setCompletionBlock:^(id success) {
        XCTAssertFalse(success);
        [expectation fulfill];
    }];
    [command setFailedBlock:^(NSError *error) {
        XCTAssertTrue(ConfigurationRequestError == error.code);
        [expectation fulfill];
    }];
    
    [command start];
    
    [self waitForExpectationsWithTimeout:MAX_RESPONSE_TIME handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];  
}

- (void)testShouldRegisterDeviceSuccessfully {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"configurationCommand"];
    
    ConfigurationCommand *command = [[ConfigurationCommand alloc] initWithConfiguration:configuration];
    command.data = configuration.deviceInformation;
    [command setCompletionBlock:^(id success) {
        XCTAssertTrue(success);
        [expectation fulfill];
    }];
    [command setFailedBlock:^(NSError *error) {
        XCTAssertFalse(1);
        [expectation fulfill];
    }];
    
    [command start];
    
    [self waitForExpectationsWithTimeout:MAX_RESPONSE_TIME handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }]; 
}

@end

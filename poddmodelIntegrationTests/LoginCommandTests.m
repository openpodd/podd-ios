//
//  LoginCommandTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/19/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LoginCommand.h"
#import "ConfigurationManager.h"
#import "podderror.h"

#define MAX_RESPONSE_TIME 3

@interface LoginCommandTests : XCTestCase {
    ConfigurationManager *configuration;
}

@end

@implementation LoginCommandTests

- (void)setUp {
    
    [super setUp];
    configuration = [[ConfigurationManager alloc] init];
}

- (void)tearDown {
    
    [configuration setEndpoint:nil];
    [super tearDown];
}

- (void)testShouldNotResponseToLoginApi {
    
    [configuration setEndpoint:@""];
    
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"loginCommand"];
    
    LoginCommand *command = [[LoginCommand alloc] initWithConfiguration:configuration];
    [command setUsername:@"podd-01" withPassword:@"123098"];
    [command setCompletionBlock:^(id success) {
        XCTAssertFalse(success);
        [loginExpectation fulfill];
    }];
    [command setFailedBlock:^(NSError *error) {
        XCTAssertTrue([NSURLErrorDomain isEqualToString:error.domain]);
        [loginExpectation fulfill];
    }];
    
    [command start];
    
    [self waitForExpectationsWithTimeout:MAX_RESPONSE_TIME handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)testShouldLoginSuccessfully {
    
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"loginCommand"];
    
    LoginCommand *command = [[LoginCommand alloc] initWithConfiguration:configuration];
    [command setUsername:@"podd-01" withPassword:@"123098"];
    [command setCompletionBlock:^(id success){
        XCTAssertTrue(success);
        [loginExpectation fulfill];
    }];
    [command setFailedBlock:^(NSError *error) {
        XCTAssertFalse(AuthorizationRequestError == error.code);
        [loginExpectation fulfill];
    }];
    
    [command start];
    
    [self waitForExpectationsWithTimeout:MAX_RESPONSE_TIME handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)testShouldLoginFailedWithIncorrectUsernameAndPassword {
    
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"loginCommand"];
    
    LoginCommand *command = [[LoginCommand alloc] initWithConfiguration:configuration];
    [command setUsername:@"podd-01" withPassword:@"xxx"];
    [command setCompletionBlock:^(id success) {
        XCTAssertFalse(success);
        [loginExpectation fulfill];
    }];
    [command setFailedBlock:^(NSError *error) {
        XCTAssertTrue(AuthorizationCredentialError == error.code);
        [loginExpectation fulfill];
    }];
    
    [command start];
    
    [self waitForExpectationsWithTimeout:MAX_RESPONSE_TIME handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

@end

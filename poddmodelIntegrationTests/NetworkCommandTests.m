//
//  NetworkCommandTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/19/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NetworkCommand.h"

@interface NetworkCommandTests : XCTestCase
@end

@implementation NetworkCommandTests

- (void)testShouldThrowExceptionToSelectorStart {
    
    @try {
        NetworkCommand *command = [[NetworkCommand alloc] init];
        XCTAssertNotNil(command);
        
        [command start];
    }
    @catch (NSException *exception) {
        XCTAssertNotNil(exception);
    }
}

- (void)testShouldThrowExceptionToSelectorEndpoint {
    
    @try {
        NetworkCommand *command = [[NetworkCommand alloc] init];
        XCTAssertNotNil(command);
        
        [command endpoint];
    }
    @catch (NSException *exception) {
        XCTAssertNotNil(exception);
    }
}

@end

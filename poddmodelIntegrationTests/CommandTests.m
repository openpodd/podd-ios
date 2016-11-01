//
//  CommandTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/19/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Command.h"

@interface CommandTests : XCTestCase

@end

@implementation CommandTests

- (void)testShouldThrowException {
    
    @try {
        Command *command = [[Command alloc] init];
        XCTAssertNotNil(command);
        
        [command start];
    }
    @catch (NSException *exception) {
        XCTAssertNotNil(exception);
    }
}

@end

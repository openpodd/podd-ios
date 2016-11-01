//
//  TransitionParserTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TransitionParser.h"

@interface TransitionParserTests : XCTestCase {
    NSDictionary *data;
}

@end

@implementation TransitionParserTests

- (void)testInit {
    
    TransitionParser *parser = [TransitionParser new];
    XCTAssertNotNil(parser);
}

- (void)testShouldReturnParsedData {
    
    data = @{ 
             @"expression": @"true",
             @"from": @3,
             @"order": @0,
             @"to": @271
             };
    
    TransitionParser *parser = [TransitionParser new];
    Transition *transition = [parser parse:data];
    XCTAssertNotNil(transition);
    XCTAssertTrue([@"true" isEqualToString:transition.expression]);
    XCTAssertTrue(3 == transition.from);
    XCTAssertTrue(0 == transition.order);
    XCTAssertTrue(271 == transition.to);
}

@end

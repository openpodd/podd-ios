//
//  ContextTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/13/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Context.h"

@interface ContextTests : XCTestCase {
    NSString *formKey;
}
@end

@implementation ContextTests

- (void)setUp {
    
    [super setUp];
    formKey = @"test";
}

- (void)testInit {

    Context *context = [Context new];
    XCTAssertNotNil(context);
}

- (void)testShouldSetFormValueAsString {
    
    Context *context = [Context new];
    [context setFormValue:@"a" forKey:formKey];
    XCTAssertTrue([@"a" isEqualToString:[context formValueForKey:formKey]]);
}

- (void)testShouldSetFormValueAsNumber {
    
    Context *context = [Context new];
    [context setFormValue:@1 forKey:formKey];
    XCTAssertTrue([@1 isEqualToNumber:[context formValueForKey:formKey]]);
}

- (void)testShouldSetFormValueAsFloat {
    
    Context *context = [Context new];
    [context setFormValue:@(0.0001) forKey:formKey];
    XCTAssertTrue([@(0.0001) isEqualToNumber:[context formValueForKey:formKey]]);
}

- (void)testShouldSetFormValueAsDate {
    
    NSDate *date = [NSDate date];
    Context *context = [Context new];
    [context setFormValue:date forKey:formKey];
    XCTAssertTrue([date isEqualToDate:[context formValueForKey:formKey]]);
    
    date = [date dateByAddingTimeInterval:1];
    XCTAssertFalse([date isEqualToDate:[context formValueForKey:formKey]]);
}

- (void)testShouldSetFormValueAsArray {
    
    NSArray *data = @[@"a", @"b"];
    Context *context = [Context new];
    [context setFormValue:data forKey:formKey];
    XCTAssertTrue([data isEqualToArray:[context formValueForKey:formKey]]);
}

@end
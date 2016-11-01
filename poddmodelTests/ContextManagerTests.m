//
//  ContextManagerTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/13/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ContextManager.h"
#import "ContextDelegate.h"
#import "Context.h"
#import "Page.h"

@interface ContextManagerTests : XCTestCase {
    NSDictionary *contextData;
    ContextManager *manager;
}

@end

@interface ContextManager (TestContext)
@property (NS_NONATOMIC_IOSONLY, readonly, strong) Context * _Nullable currentContext;
- (NSDictionary *)mergedValues:(NSDictionary *)formData;
@end

@implementation ContextManagerTests

- (void)setUp {
    
    [super setUp];
    contextData =  @{@"animal" : @"dog", @"type" : @"a"};
}

- (void)testInitWithoutData {
    
    manager = [[ContextManager alloc] init];
    XCTAssertNil([manager currentContext]);
    
    [manager newContextWithIdentifier:0];
    XCTAssertNotNil([manager currentContext]);
}

- (void)testInitWithDefaultContext {
    
    Context *context = [Context new];
    manager = [[ContextManager alloc] initWithDefaultContext:context];
    XCTAssertNotNil([manager currentContext]);
}

- (void)testShouldInitializeWithData {
    
    manager = [[ContextManager alloc] initWithData:contextData];
    XCTAssertTrue([@"dog" isEqualToString:[manager formValueForKey:@"animal"]]);
    XCTAssertTrue([@"a" isEqualToString:[manager formValueForKey:@"type"]]);
    
    [manager setFormValue:@"cat" forKey:@"animal"];
    XCTAssertTrue([@"cat" isEqualToString:[manager formValueForKey:@"animal"]]);
}

- (void)testShouldCreateNewContext {
    
    manager = [[ContextManager alloc] initWithData:contextData];
    
    XCTAssertTrue([@"dog" isEqualToString:[manager formValueForKey:@"animal"]]);
    XCTAssertTrue([@"a" isEqualToString:[manager formValueForKey:@"type"]]);
    
    [manager newContextWithIdentifier:1];
    
    XCTAssertTrue([@"dog" isEqualToString:[manager formValueForKey:@"animal"]]);
    XCTAssertTrue([@"a" isEqualToString:[manager formValueForKey:@"type"]]);
    
    [manager setFormValue:@"bat" forKey:@"animal"];
    XCTAssertTrue([@"bat" isEqualToString:[manager formValueForKey:@"animal"]]);
}

- (void)testShouldRestoreRemovedContext {
    
    manager = [[ContextManager alloc] initWithData:@{}];
    
    XCTAssertTrue(manager.currentContext.uid == DefaultContextIdentifier);
    
    [manager newContextWithIdentifier:1];
    [manager setFormValue:@"elephant" forKey:@"animal"];
    XCTAssertTrue([@"elephant" isEqualToString:[manager formValueForKey:@"animal"]]);
    
    XCTAssertTrue([manager stashContext]);
    XCTAssertNil([manager formValueForKey:@"animal"]);
    
    [manager newContextWithIdentifier:1];
    XCTAssertTrue([@"elephant" isEqualToString:[manager formValueForKey:@"animal"]]);
    
    [manager newContextWithIdentifier:2];
    [manager setFormValue:@"fox" forKey:@"animal"];
    XCTAssertTrue([@"fox" isEqualToString:[manager formValueForKey:@"animal"]]);
    
    XCTAssertTrue([manager stashContext]);
    XCTAssertTrue([@"elephant" isEqualToString:[manager formValueForKey:@"animal"]]);
    
    XCTAssertTrue([manager stashContext]);
    XCTAssertNil([manager formValueForKey:@"animal"]);
    
    XCTAssertFalse([manager stashContext]);
    
    Context *context = manager.currentContext;
    XCTAssertTrue(DefaultContextIdentifier == context.uid);
}

- (void)testShouldGetAllValues {
    
    manager = [[ContextManager alloc] init];
    
    [manager newContextWithIdentifier:1];
    [manager setFormValue:@"fox1" forKey:@"a"];
    
    [manager newContextWithIdentifier:2];
    [manager setFormValue:@"fox2" forKey:@"b"];
    
    [manager newContextWithIdentifier:3];
    [manager setFormValue:@"fox3" forKey:@"c"];
    
    NSDictionary *result = manager.values;
    XCTAssertTrue(result.count == 3);
    XCTAssertTrue([@"fox1" isEqualToString:result[@"a"]]);
    XCTAssertTrue([@"fox2" isEqualToString:result[@"b"]]);
    XCTAssertTrue([@"fox3" isEqualToString:result[@"c"]]);
}

- (void)testShoudlMergeValues {
    
    manager = [[ContextManager alloc] initWithData:@{@"a":@"fox1"}];
    
    [manager newContextWithIdentifier:1];
    [manager setFormValue:@"fox2" forKey:@"a"];
    
    NSDictionary *result = manager.values;
    XCTAssertTrue([@"fox2" isEqualToString:result[@"a"]]);
}

- (void)testShouldNotBackAtFirstStack {
    
    manager = [[ContextManager alloc] initWithData:@{}];
    XCTAssertFalse([manager stashContext]);
}

- (void)testShouldEvaluateFormDataWithDectorator {
    
    NSDictionary *formData = @{ @"1|animal" : @"dog", @"2|animal": @"cat"};
    
    manager = [[ContextManager alloc] initWithData:formData];
    NSDictionary *result = [manager mergedValues:formData];
    XCTAssertNotNil(result[@"animal"]);
    
    formData = @{ @"1|animal" : @"dog", @"2|animal": @"dog"};
    result = [manager mergedValues:formData];
    XCTAssertNotNil(result[@"animal"]);
    XCTAssertTrue([result[@"animal"] isEqualToString:@"dog"]);
}

@end
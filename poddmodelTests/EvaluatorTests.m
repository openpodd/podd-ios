//
//  EvaluatorTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/14/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Evaluator.h"

@interface EvaluatorTests : XCTestCase {
    NSString *expression;
}

@end

@implementation EvaluatorTests

- (void)testShouldEvaluateExpression {
    
    Evaluator *evaluator = [Evaluator new];
    XCTAssertTrue([evaluator evaluate:@"(a==1)" withContext:@{@"a":@1}]);
    XCTAssertFalse([evaluator evaluate:@"(a==2)" withContext:@{@"a":@1}]);
}

- (void)testMeasureEvaluation {
    
    Evaluator *evaluator = [Evaluator new];
    [self measureBlock:^{
        for (NSUInteger i = 0; i < 1; i++) {
            XCTAssertTrue([evaluator evaluate:@"(a==1)" withContext:@{@"a":@1}]);
        }
    }];
}

@end

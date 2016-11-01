//
//  QuestionTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/11/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Question.h"
#import "QuestionItem.h"
#import "StubQuestionValidation.h"
#import "RequiredQuestionValidation.h"
#import "ContextManager.h"

@interface QuestionTests : XCTestCase

@end

@implementation QuestionTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInit {
    
    Question *question = [Question new];
    
    StubQuestionValidation *questionValidation = [[StubQuestionValidation alloc] initWithResult:YES];
    [question addValidation:questionValidation];
    
    XCTAssertTrue([question validate:Nil]);
}

- (void)testShouldSetValidations {
    
    [self validateStubWithArg1:NO and:NO withResult:NO];
    [self validateStubWithArg1:NO and:YES withResult:NO];
    [self validateStubWithArg1:YES and:YES withResult:YES];
    [self validateStubWithArg1:YES and:NO withResult:NO];
}

- (void)validateStubWithArg1:(BOOL)arg1 and:(BOOL)arg2 withResult:(BOOL)result {
    
    Question *question = [Question new];
    
    StubQuestionValidation *questionValidation1 = [[StubQuestionValidation alloc] initWithResult:arg1];
    StubQuestionValidation *questionValidation2 = [[StubQuestionValidation alloc] initWithResult:arg2];
    
    [question addValidation:questionValidation1];
    [question addValidation:questionValidation2];
    
    XCTAssertTrue([question validate:Nil] == result);
}

- (void)testRequireValidation {
    
    Question *question = [Question new];
    question.name = @"deathCount";
    question.type = QUESTION_TYPE_INTEGER;

    ContextManager *contextManager = [[ContextManager alloc] initWithData:[NSDictionary new]];
    
    RequiredQuestionValidation *validation = [RequiredQuestionValidation new];
    validation.errorMessage = @"กรุณาระบุจำนวนสัตว์ตาย";
    [question addValidation:validation];
    XCTAssertFalse([question validate:contextManager]);
    
    XCTAssertFalse([question validate:contextManager]);
    XCTAssertTrue([[question validationErrors] count] > 0);
    XCTAssertTrue([question.validationErrors[0] isEqualToString:@"กรุณาระบุจำนวนสัตว์ตาย"]);

    NSNumber *cnt = [NSNumber numberWithInt:10];
    [contextManager setFormValue:cnt forKey:question.name];
    XCTAssertTrue([question validate:contextManager]);
}

- (void)testQuestionShouldHaveHiddenValueIfExist {
    
    QuestionItem *item1 = [[QuestionItem alloc] init];
    item1.identifier = @"key1";
    item1.hiddenValue = @"hidden1";
    
    Question *question = [Question new];
    question.items = @[item1];
    
    XCTAssertTrue([item1.hiddenValue isEqualToString:[question hiddenValueForItemIdentifier:item1.identifier]]);
}

- (void)testQuestionShouldNotHaveHiddenValueIfNotExist {
    
    QuestionItem *item1 = [[QuestionItem alloc] init];
    item1.identifier = @"key1";
    item1.hiddenValue = nil;
    
    Question *question = [Question new];
    question.items = @[item1];
    
    XCTAssertNil([question hiddenValueForItemIdentifier:item1.identifier]);
}

@end

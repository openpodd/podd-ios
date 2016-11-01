//
//  SingleTypedQuestionParserTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QuestionParser.h"
#import "Question.h"
#import "ContextManager.h"

@interface SingleTypedQuestionParserTests : XCTestCase {
    NSDictionary *data;
}

@end

@implementation SingleTypedQuestionParserTests

- (void)setUp {
    
    [super setUp];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *mockupPath = [bundle pathForResource:@"singleQuestionData" ofType:@"json"];
    NSData *stringData = [NSData dataWithContentsOfFile:mockupPath];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:NULL];
    data = dictionary;
}

- (void)testShouldValidateItemAsSingleTypedChoice {
    
    QuestionParser *parser = [QuestionParser new];
    Question *question = [parser parse:data];
    ContextManager *contextManager = [[ContextManager alloc] initWithData:[NSDictionary new]];
    [contextManager newContextWithIdentifier:question.uid];
    NSString *testChoice;
    
    testChoice = nil;
    [contextManager setFormValue:testChoice forKey:question.name];
    XCTAssertFalse([question validate:contextManager]);
    
    testChoice = @"";
    [contextManager setFormValue:testChoice forKey:question.name];
    XCTAssertFalse([question validate:contextManager]);
    
    testChoice = @"ตตต";
    [contextManager setFormValue:testChoice forKey:question.name];
    XCTAssertFalse([question validate:contextManager]);
    
    testChoice = @"ตายแล้ว";
    [contextManager setFormValue:testChoice forKey:question.name];
    XCTAssertTrue([question validate:contextManager]);
}

@end

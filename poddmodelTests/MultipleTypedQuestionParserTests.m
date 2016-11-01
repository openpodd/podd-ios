//
//  MultipleTypedQuestionParserTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QuestionParser.h"
#import "Question.h"
#import "ContextManager.h"

@interface MultipleTypedQuestionParserTests : XCTestCase {
    NSDictionary *data;
}

@end

@implementation MultipleTypedQuestionParserTests

- (void)setUp {
    
    [super setUp];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *mockupPath = [bundle pathForResource:@"multipleQuestionData" ofType:@"json"];
    NSData *stringData = [NSData dataWithContentsOfFile:mockupPath];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:NULL];
    data = dictionary;
}

- (void)testShouldValidateItemsAsMultipleTypedChoice {
    
    QuestionParser *parser = [QuestionParser new];
    Question *question = [parser parse:data];
    ContextManager *contextManager = [[ContextManager alloc] initWithData: [NSDictionary new]];
    [contextManager newContextWithIdentifier:1];

    NSString *testChoice;

    testChoice = nil;
    [contextManager setFormValue:testChoice forKey:question.name];
    XCTAssertFalse([question validate:contextManager]);
    
    testChoice = @"";
    [contextManager setFormValue:testChoice forKey:question.name];
    XCTAssertFalse([question validate:contextManager]);
    
    testChoice = @"ตายแล้ว";
    [contextManager setFormValue:testChoice forKey:question.name];
    XCTAssertTrue([question validate:contextManager]);
    
    testChoice = @"ยังมีชีวิตอยู่,ตายแล้ว";
    [contextManager setFormValue:testChoice forKey:question.name];
    XCTAssertTrue([question validate:contextManager]);
    
    testChoice = @"ตายแล้ว,ยังมีชีวิตอยู่";
    [contextManager setFormValue:testChoice forKey:question.name];
    XCTAssertTrue([question validate:contextManager]);
    
    testChoice = @"ตายแล้ว2";
    [contextManager setFormValue:testChoice forKey:question.name];
    XCTAssertFalse([question validate:contextManager]);
    
    testChoice = @"ตายแล้ว,ตายแล้ว2";
    [contextManager setFormValue:testChoice forKey:question.name];
    XCTAssertFalse([question validate:contextManager]);
}

@end

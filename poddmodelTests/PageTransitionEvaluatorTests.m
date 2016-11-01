//
//  PageTransitionEvaluatorTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/14/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PageTransitionEvaluator.h"
#import "FormParser.h"
#import "ContextManager.h"
#import "Page.h"
#import "Transition.h"

@class Form;

@interface PageTransitionEvaluatorTests : XCTestCase {
    Form *form;
    ContextManager *contextManager;
}

@end

@implementation PageTransitionEvaluatorTests

- (void)setUp {
    
    [super setUp];
   
    Page *page1 = [[Page alloc] initWithIdentifier:1];
    Page *page2 = [[Page alloc] initWithIdentifier:2];
    Page *page3 = [[Page alloc] initWithIdentifier:3];
    Transition *transition1 = [[Transition alloc] initWithIdentifierFrom:1 to:2 expression:@"true"];
    Transition *transition2 = [[Transition alloc] initWithIdentifierFrom:2 to:3 expression:@"false"];
    Transition *transition3 = [[Transition alloc] initWithIdentifierFrom:2 to:3 expression:@"true"];
    
    form = [[Form alloc] init];
    [form addPages:@{ @"1":page1, @"2":page2, @"3":page3}];
    [form addTransitions:@[transition1, transition2, transition3]];
}

- (void)testShouldEvaluateTransition {
    
    contextManager = [[ContextManager alloc] initWithData:@{}];
    
    PageTransitionEvaluator *evaluator = [[PageTransitionEvaluator alloc] initWithForm:form inContextManager:contextManager];
    XCTAssertNotNil(evaluator);
    
    XCTAssertTrue(2 == [evaluator evaluatePage:1]);
    XCTAssertFalse(2 == [evaluator evaluatePage:2]);
    
    Transition *transition1 = [[Transition alloc] initWithIdentifierFrom:1 to:2 expression:@"true"];
    Transition *transition2 = [[Transition alloc] initWithIdentifierFrom:2 to:3 expression:@"true"];
    Transition *transition3 = [[Transition alloc] initWithIdentifierFrom:2 to:3 expression:@"false"];
    [form addTransitions:@[transition1, transition2, transition3]];
    
    XCTAssertTrue(2 == [evaluator evaluatePage:1]);
    XCTAssertTrue(3 == [evaluator evaluatePage:2]);
}

@end

//
//  PageParserTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PageParser.h"
#import "Page.h"

#import "QuestionParser.h"
#import "Question.h"

@interface PageParserTests : XCTestCase {
    Question *mockQuestion;
    PageParser *parser;
}

@end

@implementation PageParserTests

- (void)setUp {
    
    [super setUp];
    mockQuestion = [Question newWithUid:1];
    parser = [[PageParser alloc] initWithQuestions:@[mockQuestion]];
}

- (void)testShouldReturnParsedItem {
    
    Page *page;
    NSDictionary *mockData;
    
    mockData = @{
        @"id": @1,
        @"questions": @[]
    };
    page = [parser parse:mockData];
    
    XCTAssertNotNil(page);
    XCTAssertTrue(page.uid == [mockData[@"id"] unsignedIntValue]);
    XCTAssertTrue([page.questions count] == [mockData[@"questions"] count]);
    
    
    mockData = @{
        @"id": @1,
        @"questions": @[@(mockQuestion.uid)]
    };
    page = [parser parse:mockData];
    XCTAssertNotNil(page);
    XCTAssertTrue(page.uid == [mockData[@"id"] unsignedIntValue]);
    XCTAssertTrue([page.questions count] == [mockData[@"questions"] count]);
    XCTAssertTrue([mockQuestion uid] == [mockData[@"questions"][0] unsignedIntValue]);
    
    mockData = @{
                 @"id": @1,
                 @"questions": @[@(mockQuestion.uid), @(999)]
                 };
    page = [parser parse:mockData];
    XCTAssertNotNil(page);
    XCTAssertTrue([page.questions count] == 1);
}

@end
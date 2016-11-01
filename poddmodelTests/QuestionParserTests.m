//
//  QuestionParserTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/11/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QuestionParser.h"
#import "Question.h"

@interface QuestionParserTests : XCTestCase {
    NSDictionary *data;
}

@end

@implementation QuestionParserTests

- (void)setUp {
    
    [super setUp];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *mockupPath = [bundle pathForResource:@"questionData" ofType:@"json"];
    NSData *stringData = [NSData dataWithContentsOfFile:mockupPath];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:NULL];
    data = dictionary;
}

- (void)testInit {
    
    QuestionParser *parser = [QuestionParser new];
    XCTAssertNotNil(parser);
}

- (void)testShouldParseJSON {
    
    QuestionParser *parser = [QuestionParser new];
    Question *question = [parser parse:data];
    
    XCTAssertTrue([data[@"id"] unsignedIntValue] == question.uid);
    XCTAssertTrue([data[@"title"] isEqualToString:question.title]);
    XCTAssertTrue([data[@"type"] isEqualToString:question.type]);
    XCTAssertTrue([data[@"items"] count] == question.items.count);
    
    NSString *questionName = [[@(question.uid) stringValue] stringByAppendingFormat:@"|%@", data[@"name"]];
    XCTAssertTrue([questionName isEqualToString:question.name]);
}

@end

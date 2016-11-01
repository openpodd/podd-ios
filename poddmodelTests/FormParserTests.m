//
//  FormParserTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FormParser.h"

@interface FormParserTests : XCTestCase {
    NSDictionary *data;
}
@end

@implementation FormParserTests

- (void)setUp {
    
    [super setUp];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *mockupPath = [bundle pathForResource:@"formData" ofType:@"json"];
    NSData *stringData = [NSData dataWithContentsOfFile:mockupPath];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:NULL];
    data = dictionary;
}

- (void)testInit {
    
    FormParser *parser = [FormParser new];
    XCTAssertNotNil(parser);
}

- (void)testShouldReturnParsedItem {
    
    FormParser *parser = [FormParser new];
    Form *form = [parser parse:data];
    XCTAssertNotNil(form);
    XCTAssertTrue(form.questions.count == [data[@"questions"] count]);
    XCTAssertTrue(form.pages.count == [data[@"pages"] count]);
    XCTAssertTrue(form.transitions.count == [data[@"transitions"] count]);
    XCTAssertTrue(form.startPageId == 3);
}

@end
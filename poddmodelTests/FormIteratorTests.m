//
//  FormIteratorTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/13/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FormIterator.h"
#import "FormParser.h"
#import "PageContext.h"
#import "Page.h"

@interface FormIteratorTests : XCTestCase {
    NSDictionary *data;
    Form *form;
}

@end

@implementation FormIteratorTests

- (void)setUp {
    
    [super setUp];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *mockupPath = [bundle pathForResource:@"formIteratorTestData" ofType:@"json"];
    NSData *stringData = [NSData dataWithContentsOfFile:mockupPath];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:NULL];
    data = dictionary;
    form = [[[FormParser alloc] init] parse:data];
}

- (void)testShouldTransitionToPage {

    FormIterator *formIterator = [[FormIterator alloc] initWithForm:form withData:nil];
    XCTAssertEqual(form, formIterator.form);
    
    PageContext *pageContext = formIterator.nextPage;
    XCTAssertTrue(pageContext.page.uid == 3);
    
    pageContext = formIterator.nextPage;
    XCTAssertTrue(pageContext.page.uid == 271);
    
    pageContext = formIterator.nextPage;
    XCTAssertTrue(pageContext.page.uid == 272);
}

@end

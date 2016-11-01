//
//  PageContextTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/14/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ContextManager.h"
#import "PageContext.h"
#import "Page.h"
#import "Question.h"

@interface PageContextTests : XCTestCase
@end

@implementation PageContextTests

- (void)testShouldInitializeContextWithContextManager {
    
    Page *page = [[Page alloc] initWithIdentifier:1];
    Question *question1 = [[Question alloc] init];
    question1.name = @"a";
    question1.uid = 1;
    Question *question2 = [[Question alloc] init];
    question2.name = @"b";
    question2.uid = 2;
    
    [page addQuestion:question1];
    [page addQuestion:question2];
    
    ContextManager *contextManager = [[ContextManager alloc] initWithData:@{}];
    PageContext *pageContext = [[PageContext alloc] initWithPage:page inContextManager:contextManager];
    XCTAssertTrue(2 == pageContext.questions.count);
    
    [pageContext setFormValue:@"3" forKey:@"a"];
    XCTAssertTrue([@"3" isEqualToString:[contextManager formValueForKey:@"a"]]);
    XCTAssertTrue([@"3" isEqualToString:[pageContext formValueForKey:@"a"]]);
}

@end

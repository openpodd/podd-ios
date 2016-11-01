//
//  FormIntegrationTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/14/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "XCTestCase+PreloadData.h"
#import "FormParser.h"
#import "FormIterator.h"
#import "ContextManager.h"
#import "PageContext.h"
#import "Page.h"

@interface FormIntegrationTests : XCTestCase_PreloadData {
    
}

@end

@implementation FormIntegrationTests

- (void)testScenario1 {
    
    Form *form = [self preloadData:[FormParser class] withName:@"case1"];
    FormIterator *iterator = [[FormIterator alloc] initWithForm:form withData:@{}];
    ContextManager *contextManager = iterator.contextManager;
    PageContext *pageContext;
    
    pageContext = iterator.nextPage;
    XCTAssertTrue(contextManager.values.count == 0);
    
    [pageContext setFormValue:@1 forKey:@"q1"];
    pageContext = iterator.nextPage;
    XCTAssertTrue(2 == pageContext.page.uid);
    
    [pageContext setFormValue:@3 forKey:@"q2"];
    pageContext = iterator.nextPage;
    XCTAssertTrue(3 == pageContext.page.uid);
}

- (void)testScenario2 {

    Form *form = [self preloadData:[FormParser class] withName:@"case2"];
    FormIterator *iterator = [[FormIterator alloc] initWithForm:form withData:@{}];
    ContextManager *contextManager = iterator.contextManager;
    PageContext *pageContext;
    
    pageContext = iterator.nextPage;
    XCTAssertTrue(contextManager.values.count == 0);
    
    [pageContext setFormValue:@"4" forKey:@"q1"];
    pageContext = iterator.nextPage;
    XCTAssertTrue(4 == pageContext.page.uid);
    
    [pageContext setFormValue:@"3" forKey:@"q4"];
    pageContext = iterator.nextPage;
    XCTAssertTrue(3 == pageContext.page.uid);
}

@end

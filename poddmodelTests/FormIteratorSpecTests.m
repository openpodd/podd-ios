//
//  FormIteratorSpecTests.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/15/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FormParser.h"
#import "FormIterator.h"
#import "ContextManager.h"
#import "Context.h"
#import "PageContext.h"
#import "Page.h"
#import "Transition.h"

#define DefaultContext @"-1"
static const NSInteger PAGE_NOT_FOUND = -1;

@interface FormIteratorSpecTests : XCTestCase {
    Form *form;
    FormIterator *iterator;
    ContextManager *contextManager;
    
    PageContext *pageContext;
    Context *context;
    NSArray *expectedContextUids;
    NSArray *expectedStashedContextUids;
}

@end

@interface ContextManager (Test)
@property (NS_NONATOMIC_IOSONLY, readonly, strong) Context *currentContext;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray<Context *> *contextUids;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray<NSString *> *stashContextUids;
@end

@implementation FormIteratorSpecTests

- (void)tearDown {
    
    [super tearDown];
    pageContext = nil;
    context = nil;
    expectedContextUids = nil;
    expectedStashedContextUids = nil;
}

- (void)setUp {
    
    [super setUp];
    
    Question *question1 = [[Question alloc] initWithIdentifier:1];
    Question *question2 = [[Question alloc] initWithIdentifier:2];
    Question *question3 = [[Question alloc] initWithIdentifier:3];
    
    Page *page1 = [[Page alloc] initWithIdentifier:1];
    Page *page2 = [[Page alloc] initWithIdentifier:2];
    Page *page3 = [[Page alloc] initWithIdentifier:3];
    
    [page1 addQuestion:question1];
    [page2 addQuestion:question2];
    [page3 addQuestion:question3];
    
    Transition *transition1 = [[Transition alloc] initWithIdentifierFrom:1 to:2 expression:@"true"];
    Transition *transition2 = [[Transition alloc] initWithIdentifierFrom:2 to:3 expression:@"true"];
    Transition *transition3 = [[Transition alloc] initWithIdentifierFrom:2 to:3 expression:@"true"];
    
    form = [[Form alloc] init];
    form.startPageId = 1;
    [form addPages:@{@"1":page1, @"2":page2, @"3":page3}];
    [form addQuestions:@{@"1":question1, @"2":question2, @"3":question3}];
    [form addTransitions:@[transition1, transition2, transition3]];
    
    iterator = [[FormIterator alloc] initWithForm:form withData:nil];
    contextManager = iterator.contextManager; 
}

- (void)testShouldBehaveLike_First_Page_In_DefaultContext_And_Stash_Is_Empty {
    
    context = contextManager.currentContext;
    expectedContextUids = @[@"-1"]; 
    expectedStashedContextUids = @[];
    XCTAssertNil(pageContext);
    XCTAssertTrue(DefaultContextIdentifier == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]); 
}

- (void)testShouldBehaveLike_LastPage_With_Complete_All_Contexts_And_Stash_Is_Empty {
    
    context = contextManager.currentContext;
    XCTAssertTrue(DefaultContextIdentifier == context.uid);
    XCTAssertTrue([[contextManager contextUids] isEqualToArray:@[DefaultContext]]);
    
    pageContext = iterator.nextPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext, @"1"]; 
    expectedStashedContextUids = @[];
    XCTAssertTrue(1 == pageContext.page.uid);
    XCTAssertTrue(1 == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]);
    
    pageContext = iterator.nextPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext, @"1", @"2"]; 
    expectedStashedContextUids = @[];
    XCTAssertTrue(2 == pageContext.page.uid);
    XCTAssertTrue(2 == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]);
    
    pageContext = iterator.nextPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext, @"1", @"2", @"3"]; 
    expectedStashedContextUids = @[];
    XCTAssertTrue(3 == pageContext.page.uid);
    XCTAssertTrue(3 == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]);
    
    pageContext = iterator.nextPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext, @"1", @"2", @"3"]; 
    expectedStashedContextUids = @[];
    XCTAssertEqual(pageContext, LastPageContext);
    XCTAssertTrue(3 == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]);
}

- (void)testShouldMove_And_Restore_Page_With_Correct_Contexts_And_Stash_Is_Not_Empty {
    
    // ø, -1, [dc], [ø]
    context = contextManager.currentContext;
    XCTAssertTrue(DefaultContextIdentifier == context.uid);
    XCTAssertTrue([[contextManager contextUids] isEqualToArray:@[DefaultContext]]);
    
    // p1, 1, [dc, c1], [ø]
    pageContext = iterator.nextPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext, @"1"]; 
    expectedStashedContextUids = @[];
    XCTAssertTrue(1 == pageContext.page.uid);
    XCTAssertTrue(1 == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]);
    
    // ø, -1, [dc], [c1]
    pageContext = iterator.backPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext]; 
    expectedStashedContextUids = @[@"1"];
    XCTAssertNil(pageContext);
    XCTAssertTrue(DefaultContextIdentifier == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]);
    
    // p1, 1, [dc, c1], [ø]
    pageContext = iterator.nextPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext, @"1"]; 
    expectedStashedContextUids = @[];
    XCTAssertTrue(1 == pageContext.page.uid);
    XCTAssertTrue(1 == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]);
    
    // ø, -1, [dc], [c1]
    pageContext = iterator.backPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext]; 
    expectedStashedContextUids = @[@"1"];
    XCTAssertNil(pageContext);
    XCTAssertTrue(DefaultContextIdentifier == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]); 
}

- (void)testShouldMove_And_Restore_Pages_With_Correct_Contexts_And_Stash_Is_Not_Empty {
    
    // ø, -1, [dc], [ø]
    context = contextManager.currentContext;
    [context setFormValue:@"dog" forKey:@"animal"];
    [context setFormValue:@"run" forKey:@"status"];
    XCTAssertTrue(DefaultContextIdentifier == context.uid);
    XCTAssertTrue([[contextManager contextUids] isEqualToArray:@[DefaultContext]]);
    
    // p1, 1, [dc, c1], [ø]
    pageContext = iterator.nextPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext, @"1"]; 
    expectedStashedContextUids = @[];
    
    // Fix TestSpec
    // DefaultContext should be ignored
    XCTAssertFalse([@"dog" isEqualToString:[[contextManager values] valueForKey:@"animal"]]);
    XCTAssertFalse([@"run" isEqualToString:[[contextManager values] valueForKey:@"status"]]);
    
    [context setFormValue:@"dog" forKey:@"animal"];
    [context setFormValue:@"run" forKey:@"status"];
    
    XCTAssertTrue([@"dog" isEqualToString:[[contextManager values] valueForKey:@"animal"]]);
    XCTAssertTrue([@"run" isEqualToString:[[contextManager values] valueForKey:@"status"]]);
    
    XCTAssertTrue(1 == pageContext.page.uid);
    XCTAssertTrue(1 == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]);
    
    // p2, 2, [dc, c1, c2], [ø]
    pageContext = iterator.nextPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext, @"1", @"2"]; 
    expectedStashedContextUids = @[];
    XCTAssertTrue([@"dog" isEqualToString:[[contextManager values] valueForKey:@"animal"]]);
    XCTAssertTrue([@"run" isEqualToString:[[contextManager values] valueForKey:@"status"]]);
    XCTAssertTrue(2 == pageContext.page.uid);
    XCTAssertTrue(2 == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]);
    
    // p3, 3, [dc, c1, c2, c3], [ø]
    pageContext = iterator.nextPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext, @"1", @"2", @"3"]; 
    expectedStashedContextUids = @[];
    XCTAssertTrue([@"dog" isEqualToString:[[contextManager values] valueForKey:@"animal"]]);
    XCTAssertTrue([@"run" isEqualToString:[[contextManager values] valueForKey:@"status"]]);
    XCTAssertTrue(3 == pageContext.page.uid);
    XCTAssertTrue(3 == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]); 
    
    // p2, 2, [dc, c1, c2], [c3]
    pageContext = iterator.backPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext, @"1", @"2"]; 
    expectedStashedContextUids = @[@"3"];
    XCTAssertTrue([@"dog" isEqualToString:[[contextManager values] valueForKey:@"animal"]]);
    XCTAssertTrue([@"run" isEqualToString:[[contextManager values] valueForKey:@"status"]]);
    XCTAssertTrue(2 == pageContext.page.uid);
    XCTAssertTrue(2 == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]);
    
    
    // p3, 3, [dc, c1, c2, c3], [ø]
    pageContext = iterator.nextPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext, @"1", @"2", @"3"]; 
    expectedStashedContextUids = @[];
    [context setFormValue:@"cat" forKey:@"animal"];
    [context setFormValue:@"" forKey:@"status"];
    XCTAssertTrue([@"cat" isEqualToString:[[contextManager values] valueForKey:@"animal"]]);
    XCTAssertTrue([@"" isEqualToString:[[contextManager values] valueForKey:@"status"]]);
    XCTAssertTrue(3 == pageContext.page.uid);
    XCTAssertTrue(3 == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]); 
    
    // p2, 2, [dc, c1, c2], [c3]
    pageContext = iterator.backPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext, @"1", @"2"]; 
    expectedStashedContextUids = @[@"3"];
    XCTAssertTrue([@"dog" isEqualToString:[[contextManager values] valueForKey:@"animal"]]);
    XCTAssertTrue([@"run" isEqualToString:[[contextManager values] valueForKey:@"status"]]);
    XCTAssertTrue(2 == pageContext.page.uid);
    XCTAssertTrue(2 == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]);
    
    // p1, 1, [dc, c1], [c2, c3]
    pageContext = iterator.backPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext, @"1"]; 
    expectedStashedContextUids = @[@"3", @"2"];
    XCTAssertTrue([@"dog" isEqualToString:[[contextManager values] valueForKey:@"animal"]]);
    XCTAssertTrue([@"run" isEqualToString:[[contextManager values] valueForKey:@"status"]]);
    XCTAssertTrue(1 == pageContext.page.uid);
    XCTAssertTrue(1 == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]);
    
    // ø, -1, [dc], [c1, c2, c3]
    pageContext = iterator.backPage;
    context = contextManager.currentContext;
    expectedContextUids = @[DefaultContext]; 
    expectedStashedContextUids = @[@"3", @"2", @"1"];
    XCTAssertNil(pageContext);
    XCTAssertTrue(PAGE_NOT_FOUND == context.uid);
    XCTAssertTrue([expectedContextUids isEqualToArray:[contextManager contextUids]]);
    XCTAssertTrue([expectedStashedContextUids isEqualToArray:[contextManager stashContextUids]]);
}

@end
//
//  FormIterator.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/13/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "FormIterator.h"

#import "PageTransitionEvaluator.h"
#import "PageContext.h"
#import "Transition.h"
#import "Form.h"
#import "Page.h"
#import "ContextManager.h"
#import "Context.h"

PageContext *LastPageContext;

@interface FormIterator () {
    NSDictionary *_preloadData;
}
@property (strong, nonatomic, nonnull) Form *form;
@property (strong, nonatomic, nonnull) PageTransitionEvaluator *evaluator;
@property (strong, nonatomic, nullable) PageContext *curentPageContext;
@end

@implementation FormIterator

- (instancetype _Nonnull)initWithForm:(Form * _Nonnull)form withData:(NSDictionary * _Nullable)preloadData {
    
    if (self = [super init]) {
        _form = form;
        _preloadData = preloadData;
        LastPageContext = [PageContext new];
    }
    return self;
}

- (PageTransitionEvaluator *)evaluator {
    
    if (!_evaluator) {
        _evaluator = [[PageTransitionEvaluator alloc] initWithForm:self.form inContextManager:self.contextManager];
    }
    return _evaluator;
}

- (ContextManager *)contextManager {
    
    if (!_contextManager) {
        _contextManager = [[ContextManager alloc] initWithData:_preloadData];
    }
    return _contextManager;
}

@end

@implementation FormIterator (PageAccessor)

- (PageContext * _Nullable)nextPage {
    
    BOOL isStartPage = (self.curentPageContext == nil);
    if (isStartPage) {
        self.curentPageContext = [self startPage];
        
    } else {
        self.curentPageContext = [self evaluatePage];
    }
    
    return self.curentPageContext;
}

- (PageContext *)startPage {
    
    Page *nextPage = [self.form pageForIdentifier:self.form.startPageId];
    PageContext *pageContext = [[PageContext alloc]
                                initWithPage:nextPage
                                inContextManager:self.contextManager];
    
    [self.contextManager newContextWithIdentifier:nextPage.uid];
    return pageContext;
}

- (PageContext *)evaluatePage {
    
    PageContext *pageContext;
    
    int currentPageUid = self.curentPageContext.page.uid;
    int nextPageUid = [self.evaluator evaluatePage:currentPageUid];
    Page *nextPage = [self.form pageForIdentifier:nextPageUid];
    
    BOOL isLastPage = (nextPage == nil);
    if (isLastPage) {
        pageContext = LastPageContext;
        
    } else {
        pageContext = [[PageContext alloc] 
                       initWithPage:nextPage
                       inContextManager:self.contextManager];
        [self.contextManager newContextWithIdentifier:nextPage.uid];
    }
    return pageContext;
}

- (PageContext * _Nullable)backPage {
    
    if ([self.curentPageContext isEqual:LastPageContext]) {
        int currentPageUid = self.contextManager.currentContext.uid;
        Page *backPage = [self.form pageForIdentifier:currentPageUid];
        
        PageContext *pageContext;
        if (backPage) {
            pageContext = [[PageContext alloc] initWithPage:backPage inContextManager:self.contextManager];
        }
        self.curentPageContext = pageContext;
        return pageContext;
    }
    
    BOOL canStash = (self.contextManager).stashContext;
    if (!canStash) {
        return nil;
    }
        
    int currentPageUid = self.contextManager.currentContext.uid;
    Page *backPage = [self.form pageForIdentifier:currentPageUid];
        
    PageContext *pageContext;
    if (backPage) {
        pageContext = [[PageContext alloc] initWithPage:backPage inContextManager:self.contextManager];
    }
    self.curentPageContext = pageContext;
    return pageContext;
}

@end

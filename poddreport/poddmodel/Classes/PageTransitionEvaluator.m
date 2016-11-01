//
//  PageTransitionEvaluator.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/14/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "PageTransitionEvaluator.h"
#import "Transition.h"
#import "Form.h"
#import "ContextManager.h"

@interface PageTransitionEvaluator ()
@property (weak, nonatomic) Form *form;
@property (weak, nonatomic) ContextManager *contextManager;
@end

@implementation PageTransitionEvaluator

- (instancetype _Nonnull)initWithForm:(Form * _Nonnull)form inContextManager:(ContextManager * _Nonnull)contextManager {

    if (self = [super init]) {
        _form = form;
        _contextManager = contextManager;
    }
    return self;
}

@end

@implementation PageTransitionEvaluator (Evaluate)

- (int)evaluatePage:(int)currentPageId {
    
    int result = PAGE_NOT_FOUND;
    
    for (Transition *transition in self.form.transitions) {
        NSString *expression = transition.expression;
        int pageFrom = transition.from;
        int pageTo = transition.to;
        
        if (pageFrom == currentPageId) {
            NSDictionary *context = (self.contextManager).values;
            BOOL valid = [self evaluate:expression withContext:context];
            if (valid) {
                result = pageTo;
                break;
            }
        }
    }
    return result;
}

@end
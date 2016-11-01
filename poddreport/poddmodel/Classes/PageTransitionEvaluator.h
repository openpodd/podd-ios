//
//  PageTransitionEvaluator.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/14/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "Evaluator.h"

static const NSInteger PAGE_NOT_FOUND = -1;

@class Form;
@class ContextManager;

@interface PageTransitionEvaluator : Evaluator
- (instancetype _Nonnull)initWithForm:(Form * _Nonnull)form inContextManager:(ContextManager * _Nonnull)contextManager;
@end

@interface PageTransitionEvaluator (Evaluate)
- (int)evaluatePage:(int)pageId;
@end
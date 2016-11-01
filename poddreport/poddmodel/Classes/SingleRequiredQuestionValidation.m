//
//  SingleRequiredQuestionValidation.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "SingleRequiredQuestionValidation.h"
#import "Question.h"
#import "ContextManager.h"
#import "QuestionItem.h"

@implementation SingleRequiredQuestionValidation

- (BOOL)validate:(Question *)question withContextManager:(ContextManager *)contextManager {
    
    BOOL valid = [super validate:question withContextManager:contextManager];
    id value = [contextManager formValueForKey:question.name];
    
    NSArray *questionItems = [question.items valueForKeyPath:@"identifier"];
    BOOL containsValue = [questionItems containsObject:value];
    BOOL isFreeTextIdentifier = [value isEqualToString:question.freeTextId];
    
    valid = valid && (containsValue || isFreeTextIdentifier);
    return valid;
}

@end
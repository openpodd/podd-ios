//
//  MultipleRequiredQuestionValidation.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "MultipleRequiredQuestionValidation.h"
#import "Question.h"
#import "ContextManager.h"
#import "QuestionItem.h"

@implementation MultipleRequiredQuestionValidation

- (BOOL)validate:(Question *)question withContextManager:(ContextManager *)contextManager {

    id value = [contextManager formValueForKey:question.name];
    BOOL valid = [super validate:question withContextManager:contextManager];
    
    NSArray *formValues = [value componentsSeparatedByString:QuestionItemSeparatorSymbol];
    NSArray *questionItems = [question.items valueForKeyPath:@"identifier"];
    
    BOOL itemValid = YES;
    for (NSString *formValue in formValues) {
        BOOL containsValue = [questionItems containsObject:formValue];
        if (containsValue) {
            continue;
        }
        
        BOOL isFreeTextIdentifier = [formValue isEqualToString:question.freeTextId];
        if (isFreeTextIdentifier) {
            continue;
        }
        
        itemValid = NO;
    }
    
    
    valid = valid && itemValid;
    return valid;
}

@end

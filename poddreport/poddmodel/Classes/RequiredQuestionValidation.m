//
//  RequiredQuestionValication.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/11/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "RequiredQuestionValidation.h"
#import "Question.h"
#import "ContextManager.h"

@interface RequiredQuestionValidation ()
@property (copy, nonatomic, nonnull, readwrite) NSString *errorMessage;
@end

@implementation RequiredQuestionValidation

- (BOOL)validate:(Question *)question withContextManager:(ContextManager *)contextManager  {

    id value = [contextManager formValueForKey:question.name];

    if (value == nil) {
        return NO;
    }
    
    if ([question.type isEqualToString: QUESTION_TYPE_TEXT] ||
            [question.type isEqualToString:QUESTION_TYPE_SINGLE] ||
            [question.type isEqualToString:QUESTION_TYPE_MULTIPLE]) {
        return [((NSString *)value) length] > 0;
    }
    
    return YES;
}

@end

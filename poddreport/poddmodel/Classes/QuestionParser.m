//
//  QuestionParser.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/11/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "QuestionParser.h"
#import "Question.h"

#import "RequiredQuestionValidation.h"
#import "SingleRequiredQuestionValidation.h"
#import "MultipleRequiredQuestionValidation.h"
#import "QuestionItem.h"

@interface QuestionParser ()
@end

@implementation QuestionParser

@end

@implementation QuestionParser (Parse)

- (Question * _Nonnull)parse:(NSDictionary * _Nonnull)data {
    
    Question *question = [Question new];
    question.uid = [data[@"id"] unsignedIntValue];
    question.name = data[@"name"];
    question.title = data[@"title"];
    question.type = data[@"type"];
    question.freeTextName = data[@"freeTextName"];
    question.freeTextId = data[@"freeTextId"];
    question.freeTextText = data[@"freeTextText"];
    question.freeTextChoiceEnable = data[@"freeTextChoiceEnable"];
    question.hiddenName = data[@"hiddenName"];
    
    NSMutableArray *items = [NSMutableArray new];
    for (NSDictionary *item in data[@"items"]) {
        QuestionItem *questionItem = [[QuestionItem alloc] initWithData:item];
        [items addObject:questionItem];
    }
    question.items = [items copy];
    
    NSArray *validations = data[@"validations"];
    for (NSDictionary *validation in validations) {
        NSObject<QuestionValidation> *validationInstance;
        
        if ([@"single" isEqualToString:question.type]) {
            validationInstance = [SingleRequiredQuestionValidation new];
            
        } else if ([@"multiple" isEqualToString:question.type]) {
            validationInstance = [MultipleRequiredQuestionValidation new];
            
        } else {
            validationInstance = [RequiredQuestionValidation new];
        }
        
        validationInstance.errorMessage = validation[@"message"];
        [question addValidation:validationInstance];
    }
    
    return question;
}

@end

//
//  Question.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/11/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "Question.h"
#import "QuestionItem.h"

@interface Question ()
@property (strong, nonatomic, nonnull) NSMutableArray *validations;
@end;

@implementation Question

- (id)init {
    
    if (self = [super init]) {
        _validations = [NSMutableArray new];
        _validationErrors = [NSMutableArray new];
        _type = QUESTION_TYPE_TEXT;
    }
    return self;
}

- (instancetype _Nonnull)initWithIdentifier:(int)uid {
    
    if (self = [self init]) {
        _uid = uid;
    }
    return self;
}

+ (instancetype _Nonnull)newWithUid:(int)uid {
    
    Question *question = [Question new];
    question.uid = uid;
    return question;
}

- (NSString *)toFormValue:(id)value {
    if ([self.type isEqualToString:QUESTION_TYPE_SINGLE] ||
            [self.type isEqualToString:QUESTION_TYPE_MULTIPLE] ||
            [self.type isEqualToString:QUESTION_TYPE_TEXT]) {
        return value;
    }
    return [value stringValue];
}

- (id)fromFormValue:(NSString *)formValue {
    if ([self.type isEqualToString:QUESTION_TYPE_INTEGER]) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterNoStyle;
        return [f numberFromString:formValue];
    } else if ([self.type isEqualToString:QUESTION_TYPE_DOUBLE]) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        return [f numberFromString:formValue];
    }
    return formValue;
}

- (void)setName:(NSString *)name {
    
    _name = [[@(self.uid) stringValue] stringByAppendingFormat:@"|%@", name];
}

@end

@implementation Question (Validation)

- (void)addValidation:(NSObject<QuestionValidation> *)validation {
   
    [self.validations addObject:validation];
}

- (BOOL)validate:(ContextManager *)contextManager  {
    
    BOOL result = YES; 
    self.validationErrors = [NSMutableArray new];
    
    for (NSObject<QuestionValidation> *validation in self.validations) {
        BOOL valid = [validation validate:self withContextManager:contextManager];
        if (!valid) {
            NSString *errorMessage = validation.errorMessage;
            [self.validationErrors addObject:errorMessage];
        }
        result = result && valid;
    }
    return result;
}

@end

@implementation Question (HiddenValue)

- (id _Nullable)hiddenValueForItemIdentifier:(NSString * _Nonnull)identifier {
    
    for (QuestionItem *anItem in self.items) {
        if ([identifier isEqual:anItem.identifier]) {
            return anItem.hiddenValue;
        }
    }
    return nil;
}

@end
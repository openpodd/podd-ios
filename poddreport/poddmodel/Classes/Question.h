//
//  Question.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/11/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuestionValidation.h"
NS_ASSUME_NONNULL_BEGIN
@class ContextManager;
@class QuestionItem;

static NSString * _Nonnull const QuestionItemSeparatorSymbol = @",";

static NSString * _Nonnull const QUESTION_TYPE_TEXT = @"text";
static NSString * _Nonnull const QUESTION_TYPE_INTEGER = @"integer";
static NSString * _Nonnull const QUESTION_TYPE_DOUBLE = @"double";
static NSString * _Nonnull const QUESTION_TYPE_SINGLE = @"single";
static NSString * _Nonnull const QUESTION_TYPE_MULTIPLE = @"multiple";
static NSString * _Nonnull const QUESTION_TYPE_ADDRESS = @"address";
static NSString * _Nonnull const QUESTION_TYPE_AUTOCOMPLETE = @"autocomplete";
static NSString * _Nonnull const QUESTION_TYPE_DATE = @"date";

@interface Question : NSObject
@property (assign, nonatomic) int uid;
@property (copy, nonatomic, nullable) NSString *name;
@property (copy, nonatomic, nullable) NSString *title;
@property (copy, nonatomic, nullable) NSString *type;
@property (strong, nonatomic, nonnull) NSMutableArray<NSString *> *validationErrors;
@property (strong, nonatomic, nonnull) NSArray<QuestionItem *> *items;

@property (copy, nonatomic, nullable) NSString *freeTextId;
@property (copy, nonatomic, nullable) NSString *freeTextName;
@property (copy, nonatomic, nullable) NSString *freeTextText;
@property (assign, nonatomic) BOOL freeTextChoiceEnable;

@property (copy, nonatomic, nullable) NSString *filterFields;
@property (copy, nonatomic, nullable) NSString *dataUrl;
    
@property (copy, nonatomic, nullable) NSString *hiddenName;

+ (instancetype _Nonnull)newWithUid:(int)uid;
- (instancetype _Nonnull)initWithIdentifier:(int)uid;
- (NSString *)toFormValue:(id)value;
- (id)fromFormValue:(NSString *)formValue;
@end

@interface Question (Validation)
- (void)addValidation:(NSObject<QuestionValidation> * _Nonnull)validation;
- (BOOL)validate:(ContextManager *)contextManager ;
@end

@interface Question (HiddenValue)
- (id _Nullable)hiddenValueForItemIdentifier:(NSString * _Nonnull)identifier;
@end

NS_ASSUME_NONNULL_END

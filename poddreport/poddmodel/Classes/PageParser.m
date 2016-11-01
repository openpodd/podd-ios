//
//  PageParser.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "PageParser.h"
#import "Page.h"

@interface PageParser ()
@property (strong, nonatomic, nonnull) NSDictionary<id, Question *> *questionTable;
@end

@implementation PageParser

- (instancetype)initWithQuestions:(NSArray<Question *> * _Nonnull)questions {
    
    if (self = [super init]) {
        [self constructQuestionTableWithArray:questions];
    }
    return self;
}

- (void)constructQuestionTableWithArray:(NSArray<Question *> * _Nonnull)questions {
    
    NSMutableDictionary *questionTable = [NSMutableDictionary new];
    for (Question *question in questions) {
        id uid = @(question.uid);
        questionTable[uid] = question;
    }
    _questionTable = questionTable;
}

- (Question * _Nullable)questionForKey:(NSString * _Nonnull)key {
    
    if ([(self.questionTable).allKeys containsObject:key]) {
        return self.questionTable[key];
    } else {
        return nil;
    }
}

@end

@implementation PageParser (Parse)

- (Page *)parse:(NSDictionary * _Nonnull)data {
    
    Page *page = [Page new];
    
    NSArray *questions = data[@"questions"];
    
    for (NSString *key in questions) {
        Question *question = [self questionForKey:key];
        if (question) {
            [page addQuestion:question];
        }
    }
    
    page.uid = [data[@"id"] unsignedIntValue];
    return page;
}

@end
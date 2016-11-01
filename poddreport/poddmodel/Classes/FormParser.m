//
//  FormParser.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "FormParser.h"
#import "QuestionParser.h"
#import "PageParser.h"
#import "TransitionParser.h"

#import "Question.h"
#import "Page.h"
#import "Transition.h"

@interface FormParser () {
    Form *_form;
}
@end

@implementation FormParser

@end

@implementation FormParser (Parse)

- (Form *)parse:(NSDictionary *)data {

    _form = [Form new];
    _form.startPageId = [data[@"startPageId"] unsignedIntValue];
    [self parseQuestions:data[@"questions"]];
    [self parsePages:data[@"pages"]];
    [self parseTransitions:data[@"transitions"]];
    return _form;
}

- (void)parseQuestions:(NSArray *)questionItems {
    
    QuestionParser *questionParser = [QuestionParser new];
    NSMutableDictionary *questions = [NSMutableDictionary new];
    for (NSDictionary *data in questionItems) {
        Question *question = [questionParser parse:data];
        [questions setValue:question forKey:(@(question.uid)).stringValue];
    }
    
    [_form addQuestions:[questions copy]];
}

- (void)parsePages:(NSArray *)pageItems {
    
    PageParser *pageParser = [[PageParser alloc] initWithQuestions:(_form.questions).allValues];
    NSMutableDictionary *pages = [NSMutableDictionary new];
    for (NSDictionary *data in pageItems) {
        Page *page = [pageParser parse:data];
        [pages setValue:page forKey:(@(page.uid)).stringValue];
    }
    
    [_form addPages:[pages copy]];
}

- (void)parseTransitions:(NSArray *)transitionItems {
    
    TransitionParser *transitionParser = [TransitionParser new]; 
    NSMutableArray *transitions = [NSMutableArray new];
    for (NSDictionary *data in transitionItems) {
        Transition *transition = [transitionParser parse:data];
        [transitions addObject:transition];
    }
    
    [_form addTransitions:[transitions copy]];
}

@end

//
//  Form.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/9/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "Form.h"
#import "Question.h"

@interface Form ()
@property (strong, nonatomic, nonnull, readwrite) NSDictionary *pages;
@property (strong, nonatomic, nonnull, readwrite) NSDictionary *questions;
@property (strong, nonatomic, nonnull, readwrite) NSArray *transitions;
@end

@implementation Form
@end

@implementation Form (Accessors)

- (void)addQuestions:(NSDictionary * _Nonnull)questions {
    
    self.questions = questions;
}

- (void)addPages:(NSDictionary * _Nonnull)pages {
    
    self.pages = pages;
}

- (void)addTransitions:(NSArray * _Nonnull)transitions {
    
    self.transitions = transitions;
}

- (Page * _Nullable)pageForIdentifier:(int)uid {
    
    return self.pages[(@(uid)).stringValue];
}

@end
//
//  Form.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/9/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Page, Question, Transition;

@interface Form : NSObject
@property (assign, nonatomic) int startPageId;
@property (strong, nonatomic, nonnull, readonly) NSDictionary *pages;
@property (strong, nonatomic, nonnull, readonly) NSDictionary *questions;
@property (strong, nonatomic, nonnull, readonly) NSArray *transitions;
@end

@interface Form (Accessors)
- (void)addQuestions:(NSDictionary * _Nonnull)questions;
- (void)addPages:(NSDictionary * _Nonnull)pages;
- (void)addTransitions:(NSArray * _Nonnull)transitions;
- (Page * _Nullable)pageForIdentifier:(int)uid;
@end
//
//  PageParser.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Page, Question;

@interface PageParser : NSObject
- (instancetype _Nonnull)initWithQuestions:(NSArray<Question *> * _Nonnull)questions;
@end

@interface PageParser (Parse)
- (Page * _Nonnull)parse:(NSDictionary * _Nonnull)page;
@end
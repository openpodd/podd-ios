//
//  QuestionParser.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/11/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Question;

@interface QuestionParser : NSObject
@end

@interface QuestionParser (Parse)
- (Question * _Nonnull)parse:(NSDictionary * _Nonnull)data;
@end

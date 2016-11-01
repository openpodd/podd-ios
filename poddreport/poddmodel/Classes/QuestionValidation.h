//
//  QuestionValidation.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/11/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Question;
@class ContextManager;

@protocol QuestionValidation <NSObject>
- (BOOL)validate:(Question *)question withContextManager:(ContextManager *)contextManager;

- (NSString *)errorMessage;
- (void)setErrorMessage:(NSString *)errorMessage;
@end
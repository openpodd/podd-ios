//
//  StubQuestionValidation.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/11/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuestionValidation.h"

@interface StubQuestionValidation : NSObject <QuestionValidation>
- (instancetype)initWithResult:(BOOL)result NS_DESIGNATED_INITIALIZER;
@end

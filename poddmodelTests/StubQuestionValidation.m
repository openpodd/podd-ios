//
//  StubQuestionValidation.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/11/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "StubQuestionValidation.h"

@interface StubQuestionValidation ()
@property (assign, nonatomic) BOOL result;
@end

@implementation StubQuestionValidation

- (instancetype)init {
        
    return [self initWithResult:NO];
}

- (instancetype)initWithResult:(BOOL)result {
    
    if (self = [super init]) {
        _result = result;
    }
    return self;
}

- (BOOL)validate:(Question *)question withContextManager:(ContextManager *)contextManager{
    
    return self.result;
}

- (NSString *)errorMessage {
    
    return @"Error StubQuestionValidation";
}

- (void)setErrorMessage:(NSString *)errorMessage {
    
    
}

@end

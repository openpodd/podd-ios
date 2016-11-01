//
//  Evaluator.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/14/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "Evaluator.h"

@import JavaScriptCore;

@implementation Evaluator

- (BOOL)evaluate:(NSString * _Nonnull)expression withContext:(NSDictionary * _Nonnull)context {
    
    JSContext *jsContext = [[JSContext alloc] initWithVirtualMachine:[JSVirtualMachine new]];
    for (NSString *key in context.allKeys) {
        jsContext[key] = context[key];
    }
    BOOL result = [[jsContext evaluateScript:expression] toBool];
    return result;
}

@end

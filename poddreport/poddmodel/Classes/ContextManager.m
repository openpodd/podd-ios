//
//  ContextManager.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/13/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ContextManager.h"
#import "Context.h"
#import "Page.h"
#import "Form.h"

@interface ContextManager () {
    NSMutableArray<Context *> *_contexts;
    NSMutableDictionary *_stashContexts;
}
@end

@interface ContextManager (NewContext)
- (void)newContextWithData:(NSDictionary * _Nullable)data;
@end

@implementation ContextManager

- (instancetype _Nonnull)init {
    
    if (self = [super init]) {
        _contexts = [NSMutableArray new];
        _stashContexts = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype _Nonnull)initWithDefaultContext:(Context * _Nonnull)defaultContext {
    
    if (self = [self init]) {
        [_contexts addObject:defaultContext];
    }
    return self;
}

- (instancetype _Nonnull)initWithData:(NSDictionary * _Nonnull)data {

    if (self = [self init]) {
        [self newContextWithData:data];
    }
    return self;
}

#pragma mark - Context Delegate

- (void)setFormValue:(id _Nonnull)formValue forKey:(NSString * _Nonnull)key {
    
    [self.currentContext setFormValue:formValue forKey:key];
}

//
// Form Value 
//
- (id _Nullable)formValueForKey:(NSString * _Nonnull)key {
    
    NSInteger index = _contexts.count - 1;
    id value;
    while (_contexts.count > 0 && index < _contexts.count) {
        value = [_contexts[index--] formValueForKey:key]; 
        if (value) {
            break;
        }
    }
    return value;
}

//
// Merge all values without DefaultContext
//

- (NSDictionary *)formValues {
    
    NSMutableDictionary *values = [NSMutableDictionary new];
    for (Context *context in _contexts) {
        if (context.uid == DefaultContextIdentifier) {
            continue;
        }
        
        NSDictionary *contextValues = context.formValue;
        if (![contextValues isKindOfClass:[NSNull class]]) {
            [values addEntriesFromDictionary:contextValues];
        }
    }
    return values;
}

- (NSDictionary *)values {
    
    NSMutableDictionary *values = [NSMutableDictionary new];
    for (Context *context in _contexts) {
        if (context.uid == DefaultContextIdentifier) {
            continue;
        }
        
        NSDictionary *contextValues = context.formValue;
        if (![contextValues isKindOfClass:[NSNull class]]) {
            [values addEntriesFromDictionary:contextValues];
        }
    }
    
    NSDictionary *mergedValues = [self mergedValues:values];
    return mergedValues;
}

- (NSDictionary *)mergedValues:(NSDictionary *)formData {
    
    NSMutableDictionary *result = [formData mutableCopy];
    
    for (NSString *key in formData.allKeys) {
        NSRange range = [key rangeOfString:@"|"];
        
        if (range.location != NSNotFound) {
            id value = [formData valueForKey:key];
            
            // evaluate key
            NSString *newKey = [key substringFromIndex:(range.location + 1)];
            
            // determine merge attributes
            id mergedValue = [result valueForKey:newKey];
            
            BOOL shouldMergeValues = [self shouldMergeStringFromValues:mergedValue new:value];
            if (shouldMergeValues) {
                value = [self mergeStringFromValues:mergedValue new:value separator:@","];
            }
            
            [result setValue:value forKey:newKey];
            [result setValue:nil forKey:key];
        }
    }
    return [result copy];
}

- (BOOL)shouldMergeStringFromValues:(NSString *)values new:(NSString *)new {
    
    if (values == nil) {
        return NO;
    }
    
    if (![values isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    BOOL shouldMergeValue = [values containsString:new];
    return (!shouldMergeValue);
}

- (NSString *)mergeStringFromValues:(NSString *)values new:(NSString *)new separator:(NSString *)separator {
    
    assert(values);
    assert(new);
    assert(separator);
    
    NSArray<NSString *> *old = [values componentsSeparatedByString:separator];
    NSArray<NSString *> *result = [old arrayByAddingObject:new];
    return [result componentsJoinedByString:separator];
}


@end

@implementation ContextManager (NewContext)

- (void)newContextWithData:(NSDictionary * _Nullable)data {
    
    Context *context = [[Context alloc] initWithData:data == nil ? @{} : data];
    context.uid = DefaultContextIdentifier;
    [_contexts addObject:context];
}

@end

@implementation ContextManager (Context)

- (void)newContextWithIdentifier:(int)uid {
    
    Context *context = [self _createContextWithIdentifier:uid];
    [_contexts addObject:context];
}

- (Context * _Nonnull)_createContextWithIdentifier:(int)uid {
    
    Context *context = [_stashContexts valueForKey:(@(uid)).stringValue];
    if (!context) {
        context = [Context new];
        context.uid = uid;
    } else {
        [_stashContexts setValue:nil forKey:(@(uid)).stringValue];
    }
    return context;
}

- (BOOL)stashContext {
    
    Context *context = _contexts.lastObject;
    if (context.uid != DefaultContextIdentifier) {
        [_contexts removeLastObject];
        _stashContexts[(@(context.uid)).stringValue] = context;
        return YES;
        
    } else {
        return NO;
    }
}

@end

@implementation ContextManager (Accessors)

- (Context * _Nonnull)currentContext {
    
    Context *context = _contexts.lastObject;
    return context;
}

@end


@implementation ContextManager (Test)

- (NSArray<NSString *> *)contextUids {
    
    NSMutableArray *uids = [NSMutableArray new];
    for (Context *context in _contexts) {
        [uids addObject:(@(context.uid)).stringValue];
    }
    return [uids copy];
}

- (NSArray<NSString *> *)stashContextUids {
    
    NSMutableArray *uids = [NSMutableArray new];
    for (Context *context in _stashContexts.allValues) {
        [uids addObject:(@(context.uid)).stringValue];
    }
    return [uids copy];
}

@end
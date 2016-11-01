//
//  PageContext.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/14/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "PageContext.h"
#import "Page.h"
#import "ContextManager.h"

@implementation PageContext

- (instancetype)initWithPage:(Page *)page inContextManager:(ContextManager *)contextManager {
    
    if (self = [super init]) {
        _page = page;
        _contextManager = contextManager;
    }
    return self;
}

- (void)setFormValue:(NSString *)formValue forKey:(NSString *)key {
    
    for (Question *q in self.page.questions) {
        if ([q.name isEqualToString: key]) {
            id value = [q fromFormValue:formValue];
            [self.contextManager setFormValue:value forKey:key];
            return;
        }
    }
    [self.contextManager setFormValue:formValue forKey:key];
}

- (id)formValueForKey:(NSString *)key {
    
    id value = [self.contextManager formValueForKey:key];
    for (Question *q in self.page.questions) {
        if ([q.name isEqualToString:key]) {
            return [q toFormValue:value];
        }
    }
    
    if (value != nil) {
        return value;
        
    } else {
        return @"";
    }
}

@end

@implementation PageContext (Accessors)

- (NSArray<Question *> * _Nonnull)questions {
    
    return self.page.questions;
}

@end
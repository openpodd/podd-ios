//
//  Context.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/13/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "Context.h"

@interface Context ()
@property (strong, nonatomic, nullable, readwrite) NSMutableDictionary *formValue;
@end

@implementation Context

- (instancetype)init {

    if (self = [super init]) {
        _formValue = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype _Nonnull)initWithData:(NSDictionary * _Nullable)data {
    
    if (self = [super init]) {
        if (data)  {
            _formValue = [data mutableCopy];
        }
    }
    return self;
}

- (void)setFormValue:(id _Nonnull)formValue forKey:(NSString * _Nonnull)key {
    
    self.formValue[key] = formValue;
}

- (id)formValueForKey:(NSString *)key {
    
    return self.formValue[key];
}

@end

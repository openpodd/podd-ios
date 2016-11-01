//
//  QuestionItem.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/28/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "QuestionItem.h"

@implementation QuestionItem

- (instancetype _Nonnull)initWithData:(NSDictionary * _Nonnull)data {
    
    if (self = [super init]) {
        _text = data[@"text"];
        _identifier = data[@"id"];
        _hiddenValue = data[@"hiddenValue"];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    
    if ([object isKindOfClass:[self class]]) {
        return [self.identifier isEqualToString:[(QuestionItem *)object identifier]];
    }
    return [super isEqual:object];
}

@end

//
//  Page.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "Page.h"

@interface Page ()
@property (strong, nonatomic, nullable, readwrite) NSMutableArray<Question *> *questions;
@end

@implementation Page

- (instancetype)init {

    if (self = [super init]) {
        _questions = [NSMutableArray new];
    }
    return self;
}

- (instancetype)initWithIdentifier:(int)uid {
    
    if (self = [self init]) {
        _uid = uid;
    }
    return self;
}

- (void)addQuestion:(Question * _Nonnull)question {
    
    [self.questions addObject:question];
}

@end
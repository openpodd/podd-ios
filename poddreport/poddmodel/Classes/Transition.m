//
//  Transition.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "Transition.h"

@implementation Transition

- (instancetype)initWithIdentifierFrom:(int)fromUid to:(int)toUid expression:(NSString *)expression {

    if (self = [super init]) {
        _from = fromUid;
        _to = toUid;
        _expression = expression;
    }
    return self;
}

@end

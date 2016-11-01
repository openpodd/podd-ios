//
//  Command.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/19/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "Command.h"

@implementation Command

- (instancetype _Nonnull)initWithConfiguration:(id)configuration {
    
    if (self = [super init]) {
        _configuration = configuration;
    }
    return self;
}

- (void)start {
    
    @throw [NSException exceptionWithName:@"Abstract Base Class" reason:@"Must implement @selector(start)" userInfo:nil];
}

@end

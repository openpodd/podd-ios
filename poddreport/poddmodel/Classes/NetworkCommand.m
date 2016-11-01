//
//  NetworkCommand.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/19/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "NetworkCommand.h"
#import "ConfigurationManager.h"

@implementation NetworkCommand

- (NSURL * _Nonnull)endpoint {
    
    @throw [NSException exceptionWithName:@"Abstract Base Class" reason:@"Must implement @selector(endpoint)" userInfo:nil];
}

@end

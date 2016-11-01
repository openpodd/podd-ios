//
//  LoginCommand.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/19/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkCommand.h"

@interface LoginCommand : NetworkCommand
- (void)setUsername:(NSString * _Nonnull)username withPassword:(NSString * _Nonnull)password;
@end
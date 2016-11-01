//
//  Context.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/13/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContextDelegate.h"

@interface Context : NSObject <ContextDelegate>
@property (assign, nonatomic) int uid;
@property (strong, nonatomic, nullable, readonly) NSMutableDictionary *formValue;

- (instancetype _Nonnull)initWithData:(NSDictionary * _Nullable)data;
@end

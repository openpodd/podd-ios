//
//  ContextManager.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/13/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContextDelegate.h"

static const NSInteger DefaultContextIdentifier = -1;
@class Page;
@class Context;

@interface ContextManager : NSObject <ContextDelegate>
- (instancetype _Nonnull)initWithDefaultContext:(Context * _Nonnull)defaultContext;
- (instancetype _Nonnull)initWithData:(NSDictionary * _Nonnull)data;
@end

@interface ContextManager (Accessors)
- (Context * _Nonnull)currentContext;
@end

@interface ContextManager (Context)
- (void)newContextWithIdentifier:(int)uid;
- (BOOL)stashContext;
- (NSDictionary * _Nullable)values;
- (NSDictionary * _Nullable)formValues;
- (NSDictionary *)mergedValues:(NSDictionary *)formData;
@end

//
//  PageContext.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/14/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContextDelegate.h"

@class Page;
@class Question;
@class ContextManager;

@interface PageContext : NSObject <ContextDelegate>
- (instancetype _Nonnull)initWithPage:(Page * _Nullable)page inContextManager:(ContextManager * _Nullable)contextManager;
@property (weak, nonatomic, nullable) Page *page;
@property (weak, nonatomic) ContextManager *contextManager;
@end

@interface PageContext (Accessors)
- (NSArray<Question *> * _Nonnull)questions;
@end

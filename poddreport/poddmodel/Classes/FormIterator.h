//
//  FormIterator.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/13/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Form;
@class PageContext;
@class ContextManager;

extern PageContext * _Nullable LastPageContext;

@interface FormIterator : NSObject
@property (strong, nonatomic, nullable) ContextManager *contextManager;
- (instancetype _Nonnull)initWithForm:(Form * _Nonnull)form withData:(NSDictionary * _Nullable)preloadData;
@end

@interface FormIterator (FormAccessors)
- (Form * _Nonnull)form;
@end

@interface FormIterator (PageAccessors)
- (PageContext * _Nullable)nextPage;
- (PageContext * _Nullable)backPage;
@end

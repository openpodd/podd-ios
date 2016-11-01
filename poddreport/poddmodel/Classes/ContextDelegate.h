//
//  ContextDelegate.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/13/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContextDelegate <NSObject>
- (void)setFormValue:(id _Nonnull)formValue forKey:(NSString * _Nonnull)key;
- (id _Nullable)formValueForKey:(NSString * _Nonnull)key;
@end

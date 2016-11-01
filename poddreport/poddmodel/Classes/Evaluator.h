//
//  Evaluator.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/14/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Evaluator : NSObject
- (BOOL)evaluate:(NSString * _Nonnull)expression withContext:(NSDictionary * _Nonnull)context;
@end

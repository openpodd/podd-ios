//
//  CommandProtocol.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/19/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#ifndef CommandProtocol_h
#define CommandProtocol_h

typedef void (^CommandCompletionBlock)(NSDictionary  * _Nonnull params);
typedef void (^CommandFailedBlock)(NSError * _Nullable error);

@class ConfigurationManager;
@protocol CommandProtocol <NSObject>
- (instancetype _Nonnull)initWithConfiguration:(ConfigurationManager * _Nullable)configuration;
- (void)setCompletionBlock:(CommandCompletionBlock _Nullable)completionBlock;
- (void)setFailedBlock:(CommandFailedBlock _Nullable)failedBlock;
- (void)start;
@end

#endif /* CommandProtocol_h */

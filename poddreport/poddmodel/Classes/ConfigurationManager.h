//
//  Configuration.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/19/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * _Nonnull const ConfigurationFileName = @"Configuration";

@interface ConfigurationManager : NSObject
- (instancetype _Nonnull)initWithConfigurations:(NSDictionary * _Nullable)configurations;
+ (instancetype _Nonnull)sharedConfiguration;
@end

@interface ConfigurationManager (API)
@property (copy, nonatomic, nullable) NSString * endpoint;
@end

@interface ConfigurationManager (AWS)
@property (copy, nonatomic, nullable, readonly) NSString *AWSSecretKey;
@property (copy, nonatomic, nullable, readonly) NSString *AWSAccessKey;
@end

@interface ConfigurationManager (Device)
- (NSDictionary * _Nullable)deviceInformation;
@end

@interface ConfigurationManager (Authentication)
- (void)setAuthenticatedUser:(NSDictionary * _Nullable)user;
- (void)setAuthenticationToken:(NSString * _Nullable)token;
- (NSString * _Nullable)authenticationToken;
- (NSDictionary * _Nullable)authenticationUser;
@end

@interface ConfigurationManager (Sync)
- (BOOL)setConfigurationResponse:(NSDictionary * _Nonnull)configurationResponse;
@end

@interface ConfigurationManager (AdministrationAreas)
@property (strong, nonatomic, nonnull) NSArray<NSDictionary *> *administrationAreas;
@end

@class ReportType;
@interface ConfigurationManager (ReportTypes)
@property (strong, nonatomic, nonnull) NSArray<ReportType *> *reportTypes;
- (void)removeAllReportTypes;
@end

@interface ConfigurationManager (Queue)
@property (strong, nonatomic, nullable, readonly) NSNumber *operationTimeout;
@end
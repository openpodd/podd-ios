//
//  Configuration.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/19/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ConfigurationManager.h"

@interface ConfigurationManager ()
@property (strong, nonatomic) NSDictionary *variables;
@end

@interface ConfigurationManager (DocumentPaths)
- (NSString * _Nonnull)administrationAreasPath;
- (NSString * _Nonnull)reportTypesPath;
@end


@implementation ConfigurationManager

+ (instancetype)sharedConfiguration {
    static ConfigurationManager *sharedConfiguration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfiguration = [[self alloc] init];
    });
    return sharedConfiguration;
}

- (instancetype)init {
    
    if (self = [super init]) {
        NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
        NSString *configurationPath = [mainBundle
                                       pathForResource:ConfigurationFileName
                                       ofType:@"plist"];
        NSDictionary *configurations = [NSDictionary 
                                        dictionaryWithContentsOfFile:
                                        configurationPath];
        _variables = configurations;
    }
    return self;
}

- (instancetype _Nonnull)initWithConfigurations:(NSDictionary * _Nullable)configurations {
    
    if (self = [super init]) {
        _variables = configurations;
    }
    return self;
}

@end

@implementation ConfigurationManager (API)

- (NSString *)endpoint {
    
    NSString *customEndpoint = [[NSUserDefaults standardUserDefaults] stringForKey:@"custom-endpoint"];
    if (customEndpoint != nil || customEndpoint.length > 0) {
        return customEndpoint;
    }
    
    return self.variables[@"endpoint"];
}

- (void)setEndpoint:(NSString *)endpoint {
    
    [[NSUserDefaults standardUserDefaults] setValue:endpoint forKey:@"custom-endpoint"];
}

@end


@implementation ConfigurationManager (AWS)

- (NSString * _Nullable)AWSSecretKey {
    
    return [NSUserDefaults.standardUserDefaults stringForKey:@"awsSecretKey"];
}

- (NSString * _Nullable)AWSAccessKey {
    
    return [NSUserDefaults.standardUserDefaults stringForKey:@"awsAccessKey"];
}

@end


@import UIKit.UIDevice;
@implementation ConfigurationManager (Device)

- (NSString *)pushNotificationToken {
    
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"];
}

- (NSDictionary *)deviceInformation {
    
    UIDevice *device = [UIDevice currentDevice];
    NSString *model = device.systemName;
    NSString *brand = @"iPhone";
    NSString *identifier = [[device identifierForVendor] UUIDString];
    NSMutableDictionary *info = [NSMutableDictionary new];
    [info setValue:model forKey:@"model"];
    [info setValue:brand forKey:@"brand"];
    [info setValue:identifier forKey:@"deviceId"];
    [info setValue:self.pushNotificationToken forKey:@"apnsId"];
    return info;
}

@end

@implementation ConfigurationManager (Authentication)

- (void)setAuthenticatedUser:(NSDictionary * _Nullable)user {
    
    NSMutableDictionary *userWithoutNulll = [NSMutableDictionary new];
    for (NSString *key in user.allKeys) {
        if (![user[key] isKindOfClass:NSNull.class]) {
            userWithoutNulll[key] = user[key];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:userWithoutNulll forKey:@"auth_user"];
}

- (void)setAuthenticationToken:(NSString * _Nullable)token {
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"auth_token"];
}

- (NSString * _Nullable)authenticationToken {
    
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"auth_token"];
    return token;
}

- (NSDictionary * _Nullable)authenticationUser {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_user"];
}

@end

@implementation ConfigurationManager (Sync)

- (BOOL)setConfigurationResponse:(NSDictionary * _Nonnull)configurationResponse {
    
    // s3 
    [[NSUserDefaults standardUserDefaults] setObject:configurationResponse[@"awsAccessKey"] forKey:@"awsAccessKey"];
    [[NSUserDefaults standardUserDefaults] setObject:configurationResponse[@"awsSecretKey"] forKey:@"awsSecretKey"];
    
    // user
    [[NSUserDefaults standardUserDefaults] setObject:configurationResponse[@"fullName"] forKey:@"fullName"];
    
    // administration area
    [self setAdministrationAreas:configurationResponse[@"administrationAreas"]];
    return YES;
}

@end

@implementation ConfigurationManager (DocumentPaths)

- (NSString * _Nonnull)administrationAreasPath {
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [documentPath stringByAppendingPathComponent:@"/administrationAreas"];
}

- (NSString * _Nonnull)reportTypesPath {
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [documentPath stringByAppendingPathComponent:@"/reportTypes"];
}

@end

@implementation ConfigurationManager (AdministrationAreas)

- (void)setAdministrationAreas:(NSArray<NSDictionary *> * _Nonnull)administrationAreas {
    
    // administration area & report type
    NSString *administrationAreasPath = self.administrationAreasPath;
    [NSKeyedArchiver archiveRootObject:administrationAreas toFile:administrationAreasPath];
}

- (NSArray<NSDictionary *> *)administrationAreas {
    
    NSString *path = [self administrationAreasPath];
    NSArray *items = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return items;
}

@end

#import "ReportType.h"

@implementation ConfigurationManager (ReportTypes)

- (void)setReportTypes:(NSArray<ReportType *> * _Nonnull)reportTypes {
    
    NSArray *sortedReportTypes = [reportTypes sortedArrayUsingComparator:[ReportType weightComparator]];
    NSString *reportTypesPath = self.reportTypesPath;
    [NSKeyedArchiver archiveRootObject:sortedReportTypes toFile:reportTypesPath];
}

- (NSArray<ReportType *> * _Nonnull)reportTypes {
    
    NSString *path = [self reportTypesPath];
    NSArray<ReportType *> *items = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (items) {
        return items;
    } else {
        return @[];
    }
}

- (void)removeAllReportTypes {
    
    [[NSFileManager defaultManager] removeItemAtPath:self.reportTypesPath error:NULL];
}

@end


@implementation ConfigurationManager (Queue)

- (NSNumber * _Nullable)operationTimeout {
    
    return self.variables[@"timeoutInSeconds"];
}

@end
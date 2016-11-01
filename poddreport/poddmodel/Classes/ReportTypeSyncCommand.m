//
//  ReportTypeSyncCommand.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/21/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportTypeSyncCommand.h"
#import "ConfigurationManager.h"
#import "ReportType.h"

@interface ReportTypeSyncCommand (Merge)
/*
 * @parameters
 *   - localReportTypes
 *   - remoteReportTypes
 *
 * @return 
 * {
 *   "items": [<ReportType>]
 *   "pendingItems": [<NSNumber<int>>]
 * }
 */
+ (NSDictionary * _Nonnull)merge:(NSArray<ReportType *> * _Nonnull)localReportTypes with:(NSArray<ReportType *> * _Nonnull)remoteReportTypes;
@end

@interface ReportTypeSyncCommand (ProcessPendingItems)
- (void)performPendingItemTasksWithItems:(NSArray<ReportType *> * _Nonnull)remoteReportTypes completionBlock:(void (^)(NSArray<ReportType *> * _Nonnull))completionBlock;
@end

@implementation ReportTypeSyncCommand

- (void)start {
    
    assert(self.configuration.authenticationToken);
    
    NSURL *url = self.endpoint;
    NSString *authentication = [@"Token " stringByAppendingString:self.configuration.authenticationToken];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.allHTTPHeaderFields = @{@"Content-Type": @"application/json", @"Authorization": authentication};
    request.HTTPMethod = @"GET";
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *_response = (NSHTTPURLResponse *)response;
        NSError *_error = error;
        NSInteger statusCode = _response.statusCode;
        
        if (statusCode == 200) {
            NSDictionary *responseItems = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            NSMutableArray *remoteReportTypes = [NSMutableArray new];
            for (NSDictionary *responseItem in responseItems) {
                ReportType *reportType = [ReportType newWithData:responseItem];
                [remoteReportTypes addObject:reportType];
            }
            
            [self performPendingItemTasksWithItems:remoteReportTypes completionBlock:^(NSArray<ReportType *> *results){
                [self.configuration setReportTypes:results];
                if (self.completionBlock) self.completionBlock(@{});
            }];
            
            return;
        }
        
        if (statusCode >= 400 && statusCode < 500) {
            NSUInteger errorCode = SyncRequestError;
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _error = [NSError 
                      errorWithDomain:PODDDomain
                      code:errorCode
                      userInfo:@{
                                 @"url": _response.URL,
                                 @"httpStatusCode": @(statusCode),
                                 @"responseString": responseString
                                 }];
        }
        
        if (self.failedBlock) self.failedBlock(_error);
    }];
    [task resume];
}

- (NSURL * _Nonnull)endpoint {
    
    assert(self.configuration);
    
    NSString *path = [self.configuration.endpoint stringByAppendingString:@"/reportTypes/"]; 
    return [NSURL URLWithString:path];
}

- (NSURL * _Nonnull)endpointForId:(int)uid {
    
    assert(self.configuration);
    
    NSString *path = [self.configuration.endpoint stringByAppendingFormat:@"/reportTypes/%i/", uid]; 
    return [NSURL URLWithString:path];
}

@end


@implementation ReportTypeSyncCommand (ProcessPendingItems)

- (void)performPendingItemTasksWithItems:(NSArray<ReportType *> * _Nonnull)remoteReportTypes completionBlock:(void (^)(NSArray<ReportType *> * _Nonnull))completionBlock {
    
    NSArray *localReportTypes = self.configuration.reportTypes;
    NSDictionary *results = [[self class] merge:localReportTypes with:remoteReportTypes];
    NSArray *reportTypes = results[@"items"];
    NSArray *pendingItems = results[@"pendingItems"];
    
    __block NSMutableArray *changes = [NSMutableArray new];
    
    dispatch_group_t group = dispatch_group_create();
    for (NSNumber *uid in pendingItems) {
        dispatch_group_enter(group);
        
        NSURL *reportDetailEndpoint = [self endpointForId:uid.intValue];
        NSString *authentication = [@"Token " stringByAppendingString:self.configuration.authenticationToken];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:reportDetailEndpoint];
        request.allHTTPHeaderFields = @{@"Content-Type": @"application/json", @"Authorization": authentication};
        request.HTTPMethod = @"GET";
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *reportTypeDetailItem = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            ReportType *reportType = [ReportType newWithData:reportTypeDetailItem];
            [changes addObject:reportType];
            dispatch_group_leave(group);
        }];
        
        [task resume];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSMutableArray *results = [reportTypes mutableCopy];
        for (ReportType *change in changes) {
            NSInteger indexAtLocalItems = [results indexOfObject:change];
            if (indexAtLocalItems != NSNotFound) {
                [results replaceObjectAtIndex:indexAtLocalItems withObject:change];
            }
        }
        if (completionBlock) {
            completionBlock([results copy]);
        }
    });
}

@end

@implementation ReportTypeSyncCommand (Merge)

+ (NSDictionary * _Nonnull)merge:(NSArray<ReportType *> * _Nonnull)localReportTypes with:(NSArray<ReportType *> * _Nonnull)remoteReportTypes {
    
    NSMutableArray *inserting = [NSMutableArray new];
    NSMutableArray *updating = [NSMutableArray new];
    NSMutableArray *deleting = [NSMutableArray new];
    NSMutableArray *pending = [NSMutableArray new];
    
    // Inserting
    for (ReportType *remoteReportType in remoteReportTypes) {
        NSInteger indexAtLocalItems = [localReportTypes indexOfObject:remoteReportType];
        BOOL hasInsert = indexAtLocalItems == NSNotFound;
        if (hasInsert) {
            [inserting addObject:remoteReportType];
        }
    }
    
    // Deleting
    for (ReportType *localReportType in localReportTypes) {
        if (ReportTypeNormal == localReportType.uid) {
            [inserting addObject:localReportType];
            continue;
        }
        
        NSInteger indexAtRemoteItems = [remoteReportTypes indexOfObject:localReportType];
        BOOL hasDelete = indexAtRemoteItems == NSNotFound;
        if (hasDelete) {
            [deleting addObject:localReportType];
        }    
    }
    
    // Updating
    for (ReportType *localReportType in localReportTypes) {
        NSInteger indexAtRemoteItems = [remoteReportTypes indexOfObject:localReportType];
        BOOL hasUpdate = indexAtRemoteItems != NSNotFound;
        
        if (hasUpdate) {
            ReportType *remoteReportType = [remoteReportTypes objectAtIndex:indexAtRemoteItems];
            ReportType *mergedReportType = [localReportType copy];
            
            NSArray *mergeKeys = mergedReportType.mergeKeys;
            for (NSString *key in mergeKeys) {
                id value = [remoteReportType valueForKey:key];
                if (value != nil) {
                    [mergedReportType setValue:value forKey:key];
                }
            }
            [updating addObject:mergedReportType];
            
            if (remoteReportType.version > localReportType.version) {
                [pending addObject:@(mergedReportType.uid)];
            } else {
                
            }
        }
    }
    
    NSArray *results = [inserting arrayByAddingObjectsFromArray:updating];
    return @{ @"items": results
              ,@"pendingItems": pending
              ,@"deletingItems": deleting
              };
}

@end
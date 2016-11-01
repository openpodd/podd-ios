//
//  ReportUploadCommand.m
//  poddmodel
//
//  Created by Opendream-iOS on 2/3/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportSyncCommand.h"
#import "ReportType.h"
#import "ConfigurationManager.h"
#import "ContextManager.h"
#import <Reachability.h>

@interface ReportSyncCommand () {
    NSDateFormatter *_dateFormatter;
    NSDateFormatter *_incidentDateFormatter;
    BOOL executing;
    BOOL finished;
}
@property (weak, nonatomic, nullable) ConfigurationManager *configuration;
@property (weak, nonatomic, nullable) NSManagedObjectContext *managedObjectContext;
@property (copy, nonatomic, nonnull) NSString *guid;
@end

@interface ReportSyncCommand (CoreDataHelper)
- (ReportManagedObject * _Nullable)selectReportFromGuid:(NSString *)guid;
@end

@implementation ReportSyncCommand

- (instancetype _Nonnull)initWithGuid:(NSString *)guid managedObjectContext:(NSManagedObjectContext * _Nonnull)managedObjectContext configuration:(ConfigurationManager * _Nonnull)configuration {
    
    if (self = [super init]) {
        _configuration = configuration;
        _managedObjectContext = managedObjectContext;
        _guid = guid;
        executing = NO;
        finished = NO;
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        
        _incidentDateFormatter = [[NSDateFormatter alloc] init];
        _incidentDateFormatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        _incidentDateFormatter.timeZone = [NSTimeZone defaultTimeZone];
        [_incidentDateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    return self;
}

- (BOOL)isConcurrent {
    
    return YES;
}

- (BOOL)isExecuting {
    
    return executing;
}

- (BOOL)isFinished {
    
    return finished;
}

- (void)finish {
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    finished = YES;
    executing = NO;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (NSURL *)endpoint {
    
    NSString *path = [self.configuration.endpoint stringByAppendingString:@"/reports/"]; 
    return [NSURL URLWithString:path];
}

/**
 *
 * start URLSessionTasks
 * - select report where submitStatus == Waiting
 * - update report set submitStatus = Uploading
 * - perform uploading formData
 * - update report set submitStatus = Done (OR Failed)
 *
 **/
- (void)start {
    
    assert(self.guid);
    
    if (self.isCancelled) {
        [self finish];
        return;
    }
    
    if (![[Reachability reachabilityForInternetConnection] isReachable]) {
        [self finish];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    ReportManagedObject *report = [self selectReportFromGuid:self.guid];
    NSDictionary *payload = [self serializeReport:report];
    NSURL *url = self.endpoint;
    NSString *authentication = [@"Token " stringByAppendingString:self.configuration.authenticationToken];
    NSData *body = [NSJSONSerialization
                    dataWithJSONObject:payload
                    options:NSJSONWritingPrettyPrinted
                    error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.allHTTPHeaderFields = @{@"Content-Type": @"application/json", @"Authorization": authentication};
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    request.timeoutInterval = [[[ConfigurationManager sharedConfiguration] operationTimeout] intValue];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *_response = (NSHTTPURLResponse *)response;
        NSError *_error = error;
        NSInteger statusCode = _response.statusCode;
        
        if (_response == nil || statusCode == 0) {
            [self finish];
            return;
        }
        
        if (statusCode >= 200 && statusCode < 300) {
            NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            NSLog(@"ReportTask End %@", responseData);
            
            report.submitStatus = @(ReportSubmitStatusDone);
            
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Error %@", error);
            }
                
            [self finish];
            return;
        }
        
        if (statusCode < 500) {
            NSUInteger errorCode = InvalidFormData;
            NSString *responseString = @"UnknownError";
            if (data) {
                responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            
            _error = [NSError 
                      errorWithDomain:PODDDomain
                      code:errorCode
                      userInfo:@{
                                 @"url": _response.URL,
                                 @"httpStatusCode": @(statusCode),
                                 @"responseString": responseString
                                 }];
        }
        
        if (statusCode >= 500) {
            NSUInteger errorCode = APIInternalServerError;
            NSString *responseString = @"UnknownError";
            if (data) {
                responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            
            _error = [NSError 
                      errorWithDomain:PODDDomain
                      code:errorCode
                      userInfo:@{
                                 @"url": _response.URL,
                                 @"httpStatusCode": @(statusCode),
                                 @"responseString": responseString
                                 }]; 
        }
        
        NSLog(@"ReportTask Error %@", _error);
        [self finish];
    }];
    
    [task resume];
    
#if DEBUG
    NSLog(@"sending request %@\nBody %@"
          , request
          , [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
#endif
}

- (NSDictionary * _Nullable)serializeReport:(ReportManagedObject *)report {
    
    if (report.guid != nil
        && report.reportId.intValue != 0
        && report.reportTypeId != nil
        && report.administrationArea != nil) {
        
        NSMutableDictionary *payload = [NSMutableDictionary new];
        payload[@"date"] = [_dateFormatter stringFromDate:report.createdDate];
        payload[@"incidentDate"] = [_incidentDateFormatter stringFromDate:report.incidentDate];
        payload[@"guid"] = report.guid;
        payload[@"reportId"] = report.reportId;
        payload[@"reportTypeId"] = report.reportTypeId;
        payload[@"administrationAreaId"] = report.administrationArea;
        payload[@"testFlag"] = report.testing;
        payload[@"parentGuid"] = report.parentReportGuid;
        
        
        if (report.formData) {
            NSDictionary *formData = [NSJSONSerialization 
                                      JSONObjectWithData:[report.formData dataUsingEncoding:NSUTF8StringEncoding]
                                      options:NSJSONReadingMutableLeaves error:nil];
            
            formData = [[ContextManager new] mergedValues:formData];
            payload[@"formData"] = formData;
        }
        
        if (report.longitude && report.latitude) {
            NSDictionary *reportLocation = @{ @"latitude": report.latitude
                                              ,@"longitude" : report.longitude
                                              };
            payload[@"reportLocation"] = reportLocation;
        }
        
        if (report.reportTypeId.intValue != ReportTypeNormal) {
            payload[@"negative"] = @YES;
        }
        return payload.mutableCopy;
    }
    return nil;
}

@end

@implementation ReportSyncCommand (CoreDataHelper)

- (ReportManagedObject * _Nullable)selectReportFromGuid:(NSString *)guid {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:
                              @"guid == %@"
                              , guid];
    NSArray *reports = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return reports.firstObject;
}

@end
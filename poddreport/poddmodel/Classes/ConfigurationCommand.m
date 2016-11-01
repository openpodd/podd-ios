//
//  ConfigurationCommand.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/19/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ConfigurationCommand.h"
#import "ConfigurationManager.h"
#import "ReportType.h"

@implementation ConfigurationCommand

- (NSURL *)endpoint {
    
    NSString *path = [self.configuration.endpoint stringByAppendingString:@"/configuration/"]; 
    return [NSURL URLWithString:path];
}

- (void)start {
    
    assert(self.configuration.authenticationToken);
    assert(self.data);
    
    NSURL *url = self.endpoint;
    NSString *authentication = [@"Token " stringByAppendingString:self.configuration.authenticationToken];
    NSData *payload = [NSJSONSerialization dataWithJSONObject:self.data options:NSJSONWritingPrettyPrinted error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.allHTTPHeaderFields = @{@"Content-Type": @"application/json", @"Authorization": authentication};
    request.HTTPMethod = @"POST";
    request.HTTPBody = payload;
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *_response = (NSHTTPURLResponse *)response;
        NSError *_error = error;
        NSInteger statusCode = _response.statusCode;
        
        if (statusCode >= 200 && statusCode < 300) {
            NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            [self.configuration setConfigurationResponse:responseData];
            
            
            // Report Type
            NSMutableArray *reportTypes = [NSMutableArray new];
            for (NSDictionary *data in responseData[@"reportTypes"]) {
                ReportType *reportType = [ReportType newWithData:data];
                [reportTypes addObject:reportType];
            }
            [[ConfigurationManager sharedConfiguration] setReportTypes:reportTypes];
            
            
            
            if (self.completionBlock) self.completionBlock(@{});
            return;
        }
        
        if (statusCode >= 400 && statusCode < 500) {
            NSUInteger errorCode = ConfigurationRequestError;
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

@end

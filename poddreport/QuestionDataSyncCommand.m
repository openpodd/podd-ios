//
//  QuestionDataSyncCommand.m
//  poddreport
//
//  Created by crosalot on 4/25/17.
//  Copyright © 2017 Opendream. All rights reserved.
//

#import "QuestionDataSyncCommand.h"
#import "ConfigurationManager.h"

@implementation QuestionDataSyncCommand
    
- (void)start {
    
    //if (self.completionBlock) self.completionBlock(@{@"results": @"xxxxx"});
    // TODO: serve from cache first
    
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
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            // TODO: update responses to local cache
            
            if (self.completionBlock) self.completionBlock(response);
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
    NSString *path = [self.configuration.endpoint stringByAppendingString:self.dataUrl];
    return [NSURL URLWithString:path];
}
@end

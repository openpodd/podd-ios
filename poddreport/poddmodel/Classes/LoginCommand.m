//
//  LoginCommand.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/19/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "LoginCommand.h"
#import "CommandProtocol.h"
#import "ConfigurationManager.h"

@interface LoginCommand ()
@property (copy, nonatomic, nonnull) NSString *username;
@property (copy, nonatomic, nonnull) NSString *password;
@end

@implementation LoginCommand

- (void)start {
    
    NSURL *url = self.endpoint;
    NSDictionary *payloadDictionary = @{@"username":self.username, @"password":self.password};
    NSData *payload = [NSJSONSerialization dataWithJSONObject:payloadDictionary options:NSJSONWritingPrettyPrinted error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.allHTTPHeaderFields = @{@"Content-Type": @"application/json"};
    request.HTTPMethod = @"POST";
    request.HTTPBody = payload;
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *_response = (NSHTTPURLResponse *)response;
        NSError *_error = error;
        NSInteger statusCode = _response.statusCode;
        
        if (statusCode == 200) {
            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            [self.configuration setAuthenticatedUser:responseJSON];
            [self.configuration setAuthenticationToken:responseJSON[@"token"]];
            
            if (self.completionBlock) {
                self.completionBlock(responseJSON);
            }
            return;
        }
        
        if (statusCode >= 400 && statusCode < 500) {
            NSUInteger errorCode = AuthorizationRequestError;
            if (statusCode == 400) {
                errorCode = AuthorizationCredentialError;
            }
            
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _error = [NSError 
                      errorWithDomain:PODDDomain
                      code:errorCode
                      userInfo:@{
                                 @"url": _response.URL,
                                 @"httpStatusCode": @(statusCode),
                                 @"username":self.username,
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
                                 @"username":self.username,
                                 @"responseString": responseString
                                 }];
        }
        
        if (self.failedBlock) self.failedBlock(_error);
    }];
    [task resume];
}

- (NSURL * _Nonnull)endpoint {
    
    assert(self.configuration);
    
    NSString *path = [self.configuration.endpoint stringByAppendingString:@"/api-token-auth/"]; 
    return [NSURL URLWithString:path];
}

- (void)setUsername:(NSString * _Nonnull)username withPassword:(NSString * _Nonnull)password {
    
    _username = username;
    _password = password;
}

@end

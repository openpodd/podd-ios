//
//  CheckInvitationCodeCommand.m
//  poddreport
//
//  Created by polawat phetra on 2/15/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "CheckInvitationCodeCommand.h"
#import "ConfigurationManager.h"

@implementation CheckInvitationCodeCommand

- (void)start {
    NSURL *url = self.endpoint;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        NSHTTPURLResponse *_response = (NSHTTPURLResponse *)response;
        
        if (_response) {
            NSInteger statusCode = _response.statusCode;
            if (statusCode == 200) {
                NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
                if (self.completionBlock) {
                    self.completionBlock(@{
                                           @"authorityName": responseJSON[@"name"]
                                           });
                }
            } else {
                NSError *_error = Nil;
                
                if (statusCode == 400) {
                    _error = [NSError
                              errorWithDomain:PODDDomain
                              code:InvitationCodeUnknown
                              userInfo:Nil];
                    
                } else if (statusCode == 500) {
                    _error = [NSError
                              errorWithDomain:PODDDomain
                              code:APIInternalServerError
                              userInfo:Nil];
                }
                
                if (self.failedBlock) {
                    self.failedBlock(_error);
                }
            }
        } else {
            NSError *_error = [NSError
                      errorWithDomain:PODDDomain
                      code:APIURLInvalid
                      userInfo:Nil];
            if (self.failedBlock) {
                self.failedBlock(_error);
            }
        }

    }];
    
    [task resume];
}

- (NSURL * _Nonnull)endpoint {
    assert(self.configuration);
    NSString *path = [[self.configuration.endpoint stringByAppendingString:@"/users/register/group/code/?invitationCode="]
                      stringByAppendingString: self.invitationCode];
    return [NSURL URLWithString:path];
}
@end

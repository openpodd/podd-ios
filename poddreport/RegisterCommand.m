//
//  RegistorCommand.m
//  poddreport
//
//  Created by polawat phetra on 2/15/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "RegisterCommand.h"
#import "ConfigurationManager.h"

@implementation RegisterCommand

- (void)start {
    
    NSArray *errorMsgs = [self validate];
    if ([errorMsgs count] > 0) {
        NSError *_error = [NSError errorWithDomain:PODDDomain
                                              code:InvalidFormData
                                          userInfo:@{
                                                     @"errorMsgs": errorMsgs
                                                   }];
        if (self.failedBlock) {
            self.failedBlock(_error);
        }
    } else {
        
        
        NSDictionary *payload = [self serializeFormData];
        NSData *body = [NSJSONSerialization
                        dataWithJSONObject:payload
                        options:NSJSONWritingPrettyPrinted
                        error:nil];
        
        
        NSURL *url = self.endpoint;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.allHTTPHeaderFields = @{@"Content-Type": @"application/json"};
        request.HTTPMethod = @"POST";
        request.HTTPBody = body;
        
        NSURLSession *session = [NSURLSession sharedSession];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
            
            NSHTTPURLResponse *_response = (NSHTTPURLResponse *)response;
            NSInteger statusCode = _response.statusCode;
            if (statusCode == 201) {
                
                /* response example.
                 {
                 "id": 3902,
                 "name": "pokxx phetraxx",
                 "username": "podd.03902",
                 "firstName": "pokxx",
                 "lastName": "phetraxx",
                 "status": "ADDITION_VOLUNTEER",
                 "contact": "",
                 "avatarUrl": null,
                 "thumbnailAvatarUrl": null,
                 "authorityAdmins": [],
                 "isStaff": false,
                 "isSuperuser": false,
                 "isAnonymous": false,
                 "isPublic": false,
                 "token": "6b54599c5504d91a75183ab82fee1ce67a6f54b3",
                 "displayPassword": "29115",
                 "permissions": []
                 }
                 */
                NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
                [self.configuration setAuthenticatedUser:responseJSON];
                [self.configuration setAuthenticationToken:responseJSON[@"token"]];
                
                if (self.completionBlock) {
                    self.completionBlock(@{
                                           
                    });
                }
            } else {
                NSError *_error = Nil;
                
                if (statusCode == 400) {
                    _error = [NSError
                              errorWithDomain:PODDDomain
                              code:SubmitRegisterFormError
                              userInfo:Nil];
                    
                } else if (statusCode == 500) {
                    _error = [NSError
                              errorWithDomain:PODDDomain
                              code:APIInternalServerError
                              userInfo:Nil];
                } else if (statusCode == 0) { // when _respose is null
                    _error = [NSError
                              errorWithDomain:PODDDomain
                              code:APIURLInvalid
                              userInfo:Nil];
                }
                
                if (self.failedBlock) {
                    self.failedBlock(_error);
                }
            }
        }];
        
        [task resume];
    }
    
}

- (NSDictionary *)serializeFormData {
    NSMutableDictionary *payload = [NSMutableDictionary new];
    payload[@"firstName"] = self.firstName;
    payload[@"lastName"] = self.lastName;
    payload[@"serialNumber"] = self.identificationNumber;
    payload[@"telephone"] = self.mobileNumber;
    payload[@"email"] = self.email;
    payload[@"group"] = self.invitationCode;
    return payload.copy;
}

- (NSArray *)validate {
    NSMutableArray *errorMsgs = [[NSMutableArray alloc] init];
    if ([self.firstName length] == 0) {
        [errorMsgs addObject:@"กรุณาระบุชื่อ"];
    }
    if ([self.lastName length] == 0) {
        [errorMsgs addObject:@"กรุณาระบุนามสกุล"];
    }
    if ([self.identificationNumber length] == 0) {
        [errorMsgs addObject:@"กรุณาระบุเลขบัตรประชาชน"];
    }
    if ([self.email length] > 0 && ![self isValidEmail]) {
        [errorMsgs addObject:@"กรุณาระบุ email ให้ถูกต้อง"];
    }
    if ([self.mobileNumber length] > 0 && ![self isValidMobileNumber]) {
        [errorMsgs addObject:@"กรุณาระบุเลขหมายโทรศัพท์ให้ถูกต้อง"];
    }
    return errorMsgs;
}

-(BOOL)isValidEmail {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self.email];
}

-(BOOL)isValidMobileNumber {
    NSString *phoneRegex = @"^[0-9]{10,}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:self.mobileNumber];
}

- (NSURL * _Nonnull)endpoint {
    assert(self.configuration);
    NSString *path = [self.configuration.endpoint stringByAppendingString:@"/users/register/group/"];
    return [NSURL URLWithString:path];
}

@end

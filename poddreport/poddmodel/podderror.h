//
//  podderror.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/19/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#ifndef podderror_h
#define podderror_h

static NSString * const PODDDomain = @"org.cmonehealth.podd";

NS_ENUM(NSInteger) {
    
    // General Network Error
    APIInternalServerError = 1000,                          // HTTPError 500
    APIURLInvalid = 9001,
    
    // Login Error Domain
    AuthorizationRequestError = 1001,                       // HTTPError 400+
    AuthorizationCredentialError = 1002,                    // HTTPError 403
    
    // Register Device Domain
    ConfigurationRequestError = 2001,                       // HTTPError 400+
    
    // Registration
    InvitationCodeUnknown = 2101,
    SubmitRegisterFormError = 2102,
    
    
    // Sync Domain
    SyncRequestError = 3001, 
    
    // Report Domain
    InvalidFormData = 4001                                  // Internal Error
};

#endif /* podderror_h */

//
//  RegistorCommand.h
//  poddreport
//
//  Created by polawat phetra on 2/15/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "NetworkCommand.h"

@interface RegisterCommand : NetworkCommand

@property (copy, nonatomic, nonnull) NSString *firstName;
@property (copy, nonatomic, nonnull) NSString *lastName;
@property (copy, nonatomic, nonnull) NSString *identificationNumber;
@property (copy, nonatomic, nonnull) NSString *email;
@property (copy, nonatomic, nonnull) NSString *mobileNumber;
@property (copy, nonatomic, nonnull) NSString *invitationCode;

@end

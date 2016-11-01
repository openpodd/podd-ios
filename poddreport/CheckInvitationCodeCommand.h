//
//  CheckInvitationCodeCommand.h
//  poddreport
//
//  Created by polawat phetra on 2/15/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "NetworkCommand.h"

@interface CheckInvitationCodeCommand : NetworkCommand
@property (copy, nonatomic, nonnull) NSString *invitationCode;
@end

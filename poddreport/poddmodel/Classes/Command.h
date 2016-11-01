//
//  Command.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/19/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandProtocol.h"

@class ConfigurationManager;

@interface Command : NSObject <CommandProtocol>
@property (weak, nonatomic, nullable) ConfigurationManager *configuration;
@property (copy, nonatomic, nullable) CommandCompletionBlock completionBlock;
@property (copy, nonatomic, nullable) CommandFailedBlock failedBlock;
@end

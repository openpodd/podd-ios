//
//  LogoutCommand.h
//  poddreport
//
//  Created by Opendream-iOS on 2/4/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "Command.h"

@import CoreData;
@class ConfigurationManager;

@interface LogoutCommand : Command
- (instancetype _Nonnull)initWithManagedObjectContext:(NSManagedObjectContext * _Nonnull)managedObjectContext configuration:(ConfigurationManager * _Nonnull)configuration;
@end

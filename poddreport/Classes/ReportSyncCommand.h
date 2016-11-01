//
//  ReportUploadCommand.h
//  poddmodel
//
//  Created by Opendream-iOS on 2/3/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "NetworkCommand.h"

NS_ASSUME_NONNULL_BEGIN
@import CoreData;

@class ReportManagedObject;

@interface ReportSyncCommand : NSOperation
- (instancetype _Nonnull)initWithGuid:(NSString *)guid managedObjectContext:(NSManagedObjectContext * _Nonnull)managedObjectContext configuration:(ConfigurationManager * _Nonnull)configuration;
@end
NS_ASSUME_NONNULL_END
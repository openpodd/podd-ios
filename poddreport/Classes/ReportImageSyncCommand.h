//
//  ReportImageSyncCommand.h
//  poddreport
//
//  Created by Opendream-iOS on 2/10/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "NetworkCommand.h"

#define ThumbnailImageSize CGSizeMake(600, 600)

NS_ASSUME_NONNULL_BEGIN
@import CoreData;

@class ReportImageManagedObject;

@interface ReportImageSyncCommand : NSOperation
- (instancetype _Nonnull)initWithGuid:(NSString *)guid managedObjectContext:(NSManagedObjectContext * _Nonnull)managedObjectContext configuration:(ConfigurationManager * _Nonnull)configuration;
@end
NS_ASSUME_NONNULL_END
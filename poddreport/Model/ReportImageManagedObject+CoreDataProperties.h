//
//  ReportImageManagedObject+CoreDataProperties.h
//  poddreport
//
//  Created by Opendream-iOS on 2/2/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ReportImageManagedObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReportImageManagedObject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *guid;
@property (nullable, nonatomic, retain) NSString *imageUrl;
@property (nullable, nonatomic, retain) NSString *note;
@property (nullable, nonatomic, retain) NSString *reportGuid;
@property (nullable, nonatomic, retain) NSString *thumbnailUrl;
@property (nullable, nonatomic, retain) NSString *linkImageUrl;
@property (nullable, nonatomic, retain) NSString *linkThumbnailUrl;
@property (nullable, nonatomic, retain) NSNumber *submitStatus;
@property (nullable, nonatomic, retain) NSNumber *isUploaded;
@property (nullable, nonatomic, retain) NSNumber *isSubmitted;

@end

NS_ASSUME_NONNULL_END

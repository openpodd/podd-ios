//
//  ReportManagedObject+CoreDataProperties.h
//  poddreport
//
//  Created by Opendream-iOS on 2/3/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ReportManagedObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReportManagedObject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) NSString *formData;
@property (nullable, nonatomic, retain) NSString *guid;
@property (nullable, nonatomic, retain) NSString *parentReportGuid;
@property (nullable, nonatomic, retain) NSNumber *reportTypeId;
@property (nullable, nonatomic, retain) NSNumber *submitStatus;
@property (nullable, nonatomic, retain) NSNumber *administrationArea;
@property (nullable, nonatomic, retain) NSNumber *reportId;
@property (nullable, nonatomic, retain) NSNumber *testing;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSDate *incidentDate;
@property (nullable, nonatomic, retain) NSDate *followDate;

@end

NS_ASSUME_NONNULL_END

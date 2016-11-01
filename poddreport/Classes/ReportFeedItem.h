//
//  ReportFeedItem.h
//  poddreport
//
//  Created by Opendream-iOS on 2/23/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReportFeedItem : NSObject

@property (assign, nonatomic) int administrationAreaId;
@property (assign, nonatomic) int createdBy;
@property (assign, nonatomic) int uid;
@property (assign, nonatomic) int reportId;
@property (assign, nonatomic) int reportTypeId;
@property (assign, nonatomic) BOOL negative;
@property (assign, nonatomic) BOOL testFlag;
@property (copy, nonatomic, nullable) NSString *administrationAreaAddress;
@property (copy, nonatomic, nullable) NSString *createdByName;
@property (copy, nonatomic, nullable) NSString *firstImageThumbnail;
@property (copy, nonatomic, nullable) NSString *formDataExplanation;
@property (copy, nonatomic, nullable) NSString *guid;
@property (copy, nonatomic, nullable) NSDate *date;
@property (copy, nonatomic, nullable) NSDate *incidentDate;
@property (copy, nonatomic, nullable) NSString *reportLocation;
@property (copy, nonatomic, nullable) NSString *reportTypeName;
@property (copy, nonatomic, nullable) NSString *createdByTelephone;

- (instancetype _Nonnull)initWithDictionary:(NSDictionary * _Nonnull)dictionary;
- (NSAttributedString * _Nonnull)reportDescriptionAttributedString;

@end
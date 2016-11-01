//
//  ReportNavigationController.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/25/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "NavigationController.h"

@class ReportType;

static NSString * _Nonnull const BeginWithPageContext = @"BeginWithPageContext";
static NSString * _Nonnull const EndPageIdentifier = @"EndPageIdentifier";
static NSString * _Nonnull const ReportSummaryIdentifier = @"ReportSummaryIdentifier";

@interface ReportNavigationController : NavigationController
@property (strong, nonatomic, nullable, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, nullable) NSDate *incidentDate;
@property (assign, nonatomic) int administrationAreaId;
@property (assign, nonatomic) BOOL isSubmitted;
@property (assign, nonatomic, getter=isTesting) BOOL testing;
@end

@interface ReportNavigationController (Form)
- (ReportType * _Nonnull)reportType;
- (void)setReportType:(ReportType * _Nonnull)reportType;
- (void)setReportType:(ReportType * _Nonnull)reportType defaultData:(NSDictionary * _Nullable)data andGuid:(NSString * _Nonnull)guid;
- (void)followUpReportType:(ReportType * _Nonnull)reportType defaultData:(NSDictionary * _Nullable)data parentReportGuid:(NSString * _Nonnull)guid incidentDate:(NSDate * _Nonnull)incidentDate andAdministrationAreaId:(int)administrationAreaId;
@end

@interface ReportNavigationController (Action)
- (void)nextPage;
- (void)backPage;
- (void)submit;
@end

@interface ReportNavigationController (ReportImage)
@property (copy, nonatomic, nullable, readonly) NSString *currentReportGuid;
@end

@interface ReportNavigationController (Followable)
@property (copy, nonatomic, nonnull) NSString *parentReportGuid;
@end
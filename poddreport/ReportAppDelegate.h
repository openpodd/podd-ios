//
//  AppDelegate.h
//  ReportUI
//
//  Created by Opendream-iOS on 1/25/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic, nonnull) UIWindow *window;
@property (strong, nonatomic, nonnull) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, nonnull) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, nonnull) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@interface ReportAppDelegate (AlertController)
- (void)presentAlerWithTitle:(NSString * _Nonnull)title withMessage:(NSString * _Nonnull)message;
@end

@interface ReportAppDelegate (Form)
- (void)presentReportFormWithReportIdentifier:(id _Nonnull)identifier;
@end

@interface ReportAppDelegate (AWS)
- (void)setupAWS;
@end

@interface ReportAppDelegate (ReportSyncCommand)
- (void)startReportSync;
- (void)reportSyncCommandDidChangeData;
@end

@interface ReportAppDelegate (Login)
- (void)checkServiceAuthurization;
@end
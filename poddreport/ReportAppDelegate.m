//
//  AppDelegate.m
//  ReportUI
//
//  Created by Opendream-iOS on 1/25/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportAppDelegate.h"
#import "ReportNavigationController.h"
#import "ReportType.h"
#import "NSOperationQueue+Timeout.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@import CoreData;
@interface ReportAppDelegate ()
@property (strong, nonatomic, nullable) NSOperationQueue *commandQueue;
@end
@implementation ReportAppDelegate

#pragma mark - Application

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self managedObjectContext];
    application.statusBarStyle = UIStatusBarStyleLightContent;
    [[NSUserDefaults standardUserDefaults] setObject:@[@"th"] forKey:@"AppleLanguages"];
    [self checkServiceAuthurization];
    [self setupAppearance];
    [Fabric with:@[[Crashlytics class]]];
    [self startReportSync];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSLog(@"applicationDidBecomeActive %@", application);
    [self startReportSync];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    NSLog(@"applicationDidEnterBackground %@", application);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSError *error;
    if ([self.managedObjectContext save:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
    }
}

- (void)setupAppearance {
    
    NSDictionary *titleFontAttributes = @{ 
                                          NSFontAttributeName: [UIFont fontWithName:@"SukhumvitSet-Light" size:21],
                                          NSForegroundColorAttributeName: [UIColor whiteColor]
                                          };
    
    NSDictionary *buttonTitleFontAttributes = @{ 
                                                NSFontAttributeName: [UIFont fontWithName:@"SukhumvitSet-Light" size:17],
                                                NSForegroundColorAttributeName: [UIColor whiteColor]
                                                };
    
    [[UINavigationBar appearance] setTitleTextAttributes:titleFontAttributes];
    [[UIBarButtonItem appearance] setTitleTextAttributes:buttonTitleFontAttributes forState:UIControlStateNormal];
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0.3294 green:0.2196 blue:0.5176 alpha:1.0]];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"store.sqlite"];
    NSLog(@"storeURL %@", storeURL);
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

@end

@implementation ReportAppDelegate (AlertController)

- (void)presentAlerWithTitle:(NSString * _Nonnull)title withMessage:(NSString * _Nonnull)message {
    
    UIAlertController *alertController = [UIAlertController 
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction 
                                actionWithTitle:NSLocalizedString(@"OK", nil) 
                                style:UIAlertActionStyleDefault 
                                handler:nil]];
    
    [self.window.rootViewController.presentedViewController presentViewController:alertController
                       animated:YES 
                     completion:nil];
}

@end

#import "ReportManagedObject.h"
#import "ConfigurationManager.h"

@implementation ReportAppDelegate (Form)

- (ReportType * _Nullable)reportTypeFromUid:(int)uid {
    
    NSArray<ReportType *> *reportTypes = [[ConfigurationManager sharedConfiguration] reportTypes];
    for (ReportType *reportType in reportTypes) {
        if (uid == reportType.uid) {
            return reportType;
        }
    }
    return nil;
}

- (void)presentReportFormWithReportIdentifier:(id _Nonnull)identifier {
    
    ReportNavigationController *presentingController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (!identifier) {
        presentingController = [storyboard instantiateViewControllerWithIdentifier:@"CreateReportFormIdentifier"];
        
    } else {
        presentingController = [storyboard instantiateViewControllerWithIdentifier:@"EditReportFormIdentifier"];
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"guid == %@", identifier];
        fetchRequest.fetchLimit = 1;
        NSArray *results = [self.managedObjectContext
                            executeFetchRequest:fetchRequest
                            error:nil];
        ReportManagedObject *report = results.firstObject;
        ReportType *reportType = [self reportTypeFromUid:report.reportTypeId.intValue];
        NSData *data = [report.formData dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *formData = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingMutableLeaves
                                  error:nil];
        [presentingController setReportType:reportType defaultData:formData andGuid:report.guid];
        [presentingController setIncidentDate:report.createdDate];
        [presentingController setAdministrationAreaId:report.administrationArea.intValue];
    }
    
    [self.window.rootViewController
     presentViewController:presentingController
     animated:YES
     completion:nil];
}

@end

#import "ConfigurationManager.h"
#import <AWSCore/AWSCore.h>

@implementation ReportAppDelegate (AWS)

- (void)setupAWS {
    
    // FIXME: AccessKey and SecretKey was swapped from server
    NSString *accessKey = [[ConfigurationManager sharedConfiguration] AWSSecretKey];
    NSString *secretKey = [[ConfigurationManager sharedConfiguration] AWSAccessKey];
    
    AWSStaticCredentialsProvider *credentialsProvider;
    credentialsProvider = [[AWSStaticCredentialsProvider alloc]
                           initWithAccessKey:accessKey 
                           secretKey:secretKey];
    
    AWSServiceConfiguration *configuration;
    configuration = [[AWSServiceConfiguration alloc]
                     initWithRegion:AWSRegionAPSoutheast1
                     credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
}

@end


@implementation ReportAppDelegate (Login)

- (void)checkServiceAuthurization {
    
    BOOL hasAnAuthorizationToken = [[[ConfigurationManager sharedConfiguration] authenticationToken] length] > 0;
    if (hasAnAuthorizationToken) {
        [self setupAWS];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"LoginIdentifier"];
    UIViewController *parentController = (UITabBarController *)self.window.rootViewController;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [parentController presentViewController:controller animated:NO completion:nil];
    });
}

@end

#import "ReportSyncCommand.h"
#import "ReportImageSyncCommand.h"


@implementation ReportAppDelegate (ReportSyncCommand)

- (void)startReportSync {
    
    BOOL hasAnAuthorizationToken = [[[ConfigurationManager sharedConfiguration] authenticationToken] length] > 0;
    if (!hasAnAuthorizationToken) {
        return;
    }
    
    [self restoreReportSyncQueue];
    [self restoreReportImageSyncQueue];
    NSLog(@"Restore Operation %lu", self.commandQueue.operationCount);
}

- (void)restoreReportSyncQueue {
    
    for (ReportManagedObject *report in self.fetchReportQueue) {
        ReportSyncCommand *command = [[ReportSyncCommand alloc]
                                      initWithGuid:report.guid
                                      managedObjectContext:self.managedObjectContext
                                      configuration:[ConfigurationManager sharedConfiguration]];
        [command setCompletionBlock:^{
            [self reportSyncCommandDidChangeData];
        }];
        
        NSTimeInterval timeout = [[[ConfigurationManager sharedConfiguration] operationTimeout] intValue];
        [self.commandQueue addOperation:command timeout:timeout timeoutBlock:nil];
    }
}

- (void)restoreReportImageSyncQueue {
    
    for (ReportImageManagedObject *reportImage in self.fetchReportImageQueue) {
        ReportImageSyncCommand *command = [[ReportImageSyncCommand alloc]
                                           initWithGuid:reportImage.guid
                                           managedObjectContext:self.managedObjectContext
                                           configuration:[ConfigurationManager sharedConfiguration]];
        [command setCompletionBlock:^{
            [self reportImageSyncCommandDidChangeData];
        }];
        
        NSTimeInterval timeout = [[[ConfigurationManager sharedConfiguration] operationTimeout] intValue];
        [self.commandQueue addOperation:command timeout:timeout timeoutBlock:nil];
    }
}

- (NSArray * _Nullable)fetchReportQueue {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:
                              @"(submitStatus == %i) OR (submitStatus == %i)"
                              , ReportSubmitStatusWaiting
                              , ReportSubmitStatusFailed];
    NSArray *reports = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return reports;
}

- (NSArray * _Nullable)fetchReportImageQueue {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ReportImage"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:
                              @"(submitStatus == %i) OR (submitStatus == %i) AND (isSubmitted == NO)"
                              , ReportSubmitStatusWaiting
                              , ReportSubmitStatusFailed];
    NSArray *reportImages = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return reportImages;
}

- (NSOperationQueue *)commandQueue {
    
    if (!_commandQueue) {
        NSOperationQueue *queue = [NSOperationQueue new];
        queue.name = @"CommandQueue";
        queue.maxConcurrentOperationCount = 1;
        _commandQueue = queue;
    }
    
    return _commandQueue;
}

#pragma mark - Notification

- (void)reportSyncCommandDidChangeData {
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ReportSyncCommandDidChangeData"
     object:nil];
    
    NSLog(@"Remaining Task in Queue %tu", self.commandQueue.operationCount);
}

- (void)reportImageSyncCommandDidChangeData {
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ReportImageSyncCommandDidChangeData"
     object:nil];
    
    NSLog(@"Remaining Task in Queue %tu", self.commandQueue.operationCount);
}

@end

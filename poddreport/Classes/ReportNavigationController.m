//
//  ReportNavigationController.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/25/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportNavigationController.h"
#import "PageController.h"
#import "ReportAppDelegate.h"
#import "ImagePickerController.h"

#import "PageContext.h"
#import "FormIterator.h"
#import "ContextManager.h"
#import "Form.h"
#import "FormParser.h"
#import "FormIterator.h"
#import "ReportType.h"
#import "ConfigurationManager.h"

@import CoreLocation;

@interface ReportNavigationController () <UINavigationControllerDelegate, CLLocationManagerDelegate> {
    FormIterator *_iterator;
    ContextManager *_contextManager;
    Form *_form;
    
    ReportType *_reportType;
    NSString *_reportGuid;
    NSString *_parentReportGuid;
    
    CLLocationManager *_locationManager;
}

@property (assign, nonatomic) NSUInteger viewControllerCount;
@property (strong, nonatomic, nullable) NSManagedObjectContext *managedObjectContext;

- (CLLocation *)lastKnownLocation;
@end

@interface ReportNavigationController (Store)
- (void)addReport;
@end

@implementation ReportNavigationController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        self.delegate = self;
        
        _managedObjectContext = [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    return self;
}

#pragma mark - View

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                         target:self
                                         action:@selector(cancel)];
    self.topViewController.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    [self startLocationService];
}

- (void)cancel {
     
    [self dismissViewControllerAnimated:YES completion:nil];
    [self stopLocationService];
}

#pragma mark - Navigation Controller Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    BOOL isBackAction = self.viewControllerCount > navigationController.viewControllers.count;
    if (isBackAction) {
        [self backPage];
    }
    self.viewControllerCount = navigationController.viewControllers.count;
}

#pragma mark - CoreLocation

- (void)startLocationService {
    
    if ([CLLocationManager locationServicesEnabled]) {
        if (!_locationManager) {
            _locationManager = [[CLLocationManager alloc] init];
        }
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        _locationManager.distanceFilter = 500;
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        [_locationManager stopUpdatingLocation];
        [_locationManager startUpdatingLocation];
        
    } else {
        // Notify Error
    }
}

- (void)stopLocationService {
    
    if ([CLLocationManager locationServicesEnabled]) {
        [_locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
}

- (BOOL)canLocateUserLocation {
    
    return (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
            || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
            || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse))
    && [CLLocationManager locationServicesEnabled];
}

- (CLLocation *)lastKnownLocation {
    
    return _locationManager.location;
}

@end

@implementation ReportNavigationController (Form)

- (ReportType * _Nonnull)reportType {
    
    return _reportType;
}

//
// Add
//
- (void)setReportType:(ReportType * _Nonnull)reportType {
    
    _isSubmitted = NO;
    _reportType = reportType;
    _reportGuid = [[NSUUID UUID] UUIDString];
    self.incidentDate = [NSDate date];
    
    NSDictionary *defaultAdministrationArea = [[ConfigurationManager sharedConfiguration] administrationAreas].firstObject;
    if (defaultAdministrationArea) {
        self.administrationAreaId = [defaultAdministrationArea[@"id"] intValue];
    }
    
    FormParser *formParser = [[FormParser alloc] init];
    _form = [formParser parse:_reportType.definition];
    _iterator = [[FormIterator alloc] initWithForm:_form withData:nil];
    _contextManager = _iterator.contextManager; 
}

//
// View
//
- (void)setReportType:(ReportType * _Nonnull)reportType defaultData:(NSDictionary * _Nullable)data andGuid:(NSString * _Nonnull)guid {
    
    _isSubmitted = YES;
    _reportType = reportType;
    _reportGuid = guid;
    
    FormParser *formParser = [[FormParser alloc] init];
    _form = [formParser parse:_reportType.definition];
    _iterator = [[FormIterator alloc] initWithForm:_form withData:data];
    _contextManager = _iterator.contextManager;
}

//
// Follow up
//
- (void)followUpReportType:(ReportType * _Nonnull)reportType defaultData:(NSDictionary * _Nullable)data parentReportGuid:(NSString * _Nonnull)guid incidentDate:(NSDate * _Nonnull)incidentDate andAdministrationAreaId:(int)administrationAreaId {
    
    _isSubmitted = NO;
    _reportType = reportType;
    _parentReportGuid = guid;
    _reportGuid = [[NSUUID UUID] UUIDString];
    self.incidentDate = incidentDate;
    self.administrationAreaId = administrationAreaId;
    
    FormParser *formParser = [[FormParser alloc] init];
    _form = [formParser parse:_reportType.definition];
    _iterator = [[FormIterator alloc] initWithForm:_form withData:data];
    _contextManager = _iterator.contextManager;
}

@end

@implementation ReportNavigationController (Action)

- (void)nextPage {
    
    assert(_form);
    
    PageContext *pageContext = [_iterator nextPage];
    BOOL isLastPage = [pageContext isEqual:LastPageContext];
    if (isLastPage) {
        UIStoryboard *reportStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *controller = [reportStoryboard instantiateViewControllerWithIdentifier:ReportSummaryIdentifier];
        [self pushViewController:controller animated:YES];
        
    } else {
        UIStoryboard *reportStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PageController *pageController = [reportStoryboard instantiateViewControllerWithIdentifier:BeginWithPageContext];
        pageController.pageContext = pageContext;
        [self pushViewController:pageController animated:YES];
    }
}

- (void)backPage {
    
    [_iterator backPage];
}

- (void)submit {
    
    [self addReport];
    [self stopLocationService];
    [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate] startReportSync];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation ReportNavigationController (Store)

- (NSString *)formData {
    
    NSData *data = [NSJSONSerialization
                    dataWithJSONObject:[_contextManager formValues]
                    options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *formData = [[NSString alloc]
                          initWithData:data
                          encoding:NSUTF8StringEncoding];
    return formData;
}

- (void)addReport {
    
    ReportManagedObject *report = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"Report"
                                   inManagedObjectContext:self.managedObjectContext];
    report.guid = _reportGuid;
    report.formData = self.formData;
    report.createdDate = [NSDate date];
    report.incidentDate = self.incidentDate;
    report.administrationArea = @(self.administrationAreaId);
    report.reportTypeId = @(_reportType.uid);
    report.submitStatus = @(0); 
    report.testing = @(self.testing);
    report.reportId = @((unsigned long long)[NSDate timeIntervalSinceReferenceDate]);
    
    if (_reportType.followable && _parentReportGuid) {
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"guid == %@", _parentReportGuid];
        ReportManagedObject *parentReport = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
        
        // Update this report
        report.parentReportGuid = _parentReportGuid;
        report.createdDate = parentReport.createdDate;
        report.followDate = [NSDate date];
        
        // Update parent report
        parentReport.followDate = report.followDate;
    }
    
    if (self.lastKnownLocation) {
        CLLocation *location = self.lastKnownLocation;
        report.latitude = @(location.coordinate.latitude);
        report.longitude = @(location.coordinate.longitude);
    }
    
    [self.managedObjectContext save:nil];
    NSLog(@"SaveForm %@", report.formData);
}

@end

@implementation ReportNavigationController (ReportImage)

- (BOOL)canEditReport {
    
    if (!_reportGuid) {
        return YES;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"guid == %@", _reportGuid];
    fetchRequest.fetchLimit = 1;
    NSArray *results = [self.managedObjectContext 
                        executeFetchRequest:fetchRequest
                        error:nil];
    
    ReportManagedObject *report = results.firstObject;
    if (report.submitStatus.intValue == ReportSubmitStatusDone) {
        return NO;
        
    } else {
        return YES;
    }
}

- (NSString * _Nullable)currentReportGuid {
    
    return _reportGuid;
}

@end

@implementation ReportNavigationController (Followable)

- (void)setParentReportGuid:(NSString *)parentReportGuid {
    
    _parentReportGuid = parentReportGuid;
}

- (NSString *)parentReportGuid {
    
    return _parentReportGuid;
}

@end
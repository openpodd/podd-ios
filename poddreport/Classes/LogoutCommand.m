//
//  LogoutCommand.m
//  poddreport
//
//  Created by Opendream-iOS on 2/4/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "LogoutCommand.h"


#import "ConfigurationManager.h"

@import CoreData;

@interface LogoutCommand ()
@property (weak, nonatomic, nullable) NSManagedObjectContext *managedObjectContext;
@end

@implementation LogoutCommand

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext configuration:(ConfigurationManager *)configuration {
    
    if (self = [super initWithConfiguration:configuration]) {
        _managedObjectContext = managedObjectContext;
    }
    return self;
}

- (void)start {
    
    ConfigurationManager *manager = [ConfigurationManager sharedConfiguration];
    [manager setAuthenticationToken:nil];
    [manager setAuthenticatedUser:nil];
    [manager setReportTypes:@[]];
    [manager setAdministrationAreas:@[]];
    
    NSFetchRequest *reportFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
    NSArray *reports = [self.managedObjectContext executeFetchRequest:reportFetchRequest error:nil];
    for (ReportManagedObject *report in reports) {
        [self.managedObjectContext deleteObject:report];
    }
    
    NSFetchRequest *reportImageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ReportImage"];
    NSArray *reportImages = [self.managedObjectContext executeFetchRequest:reportImageFetchRequest error:nil];
    for (ReportImageManagedObject *reportImage in reportImages) {
        [self.managedObjectContext deleteObject:reportImage];
    }
    
    NSError *error;
    BOOL success = [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Error on deleting reports %@", error);
    }
    
    if (self.completionBlock) {
        self.completionBlock(@{
                               @"success": @YES
                               });
    }
}

@end

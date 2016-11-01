//
//  TestCaseWithInMemoryDatastore.m
//  poddreport
//
//  Created by Opendream-iOS on 2/3/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "TestCaseWithInMemoryDatastore.h"

@implementation TestCaseWithInMemoryDatastore

- (void)setUp {
    
    [super setUp];
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"]; 
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    self.store = [self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
}

- (void)tearDown {
    
    [self.persistentStoreCoordinator removePersistentStore:self.store error:nil];
    [super tearDown];
}

@end

//
//  TestCaseWithInMemoryDatastore.h
//  poddreport
//
//  Created by Opendream-iOS on 2/3/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>
@import CoreData;

@interface TestCaseWithInMemoryDatastore : XCTestCase
@property (strong, nonatomic, nonnull) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, nonnull) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, nonnull) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic, nonnull) NSPersistentStore *store;
@end

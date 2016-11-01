//
//  ReportImageManagedObject.h
//  poddreport
//
//  Created by Opendream-iOS on 2/1/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReportImageManagedObject : NSManagedObject

- (NSURL * _Nonnull)referenceURL;

@end

NS_ASSUME_NONNULL_END

#import "ReportImageManagedObject+CoreDataProperties.h"

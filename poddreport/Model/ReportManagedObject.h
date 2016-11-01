//
//  ReportManagedObject.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/28/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN
@interface ReportManagedObject : NSManagedObject

- (NSString * _Nonnull)submitStatusString;

@end

NS_ASSUME_NONNULL_END

#import "ReportManagedObject+CoreDataProperties.h"
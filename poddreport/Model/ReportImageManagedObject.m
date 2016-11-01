//
//  ReportImageManagedObject.m
//  poddreport
//
//  Created by Opendream-iOS on 2/1/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportImageManagedObject.h"

@implementation ReportImageManagedObject

- (NSURL * _Nonnull)referenceURL {
    
    return [NSURL URLWithString:self.imageUrl];
}

@end

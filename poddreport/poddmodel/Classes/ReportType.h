//
//  ReportType.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/21/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

static const int ReportTypeNormal = 0;

@interface ReportType : NSObject <NSCoding, NSCopying>

@property (assign, nonatomic) int uid;
@property (assign, nonatomic) int version;
@property (assign, nonatomic) int weight;
@property (assign, nonatomic) int followDays;
@property (assign, nonatomic) BOOL followable;
@property (copy, nonatomic, nonnull) NSString *name;
@property (copy, nonatomic, nullable) NSDictionary *definition;

+ (instancetype _Nonnull)newWithData:(NSDictionary * _Nonnull)data;
- (NSArray<NSString *> * _Nonnull)mergeKeys;
+ (NSComparator _Nonnull)weightComparator;

@end

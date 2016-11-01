//
//  ReportType.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/21/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportType.h"

@implementation ReportType

- (instancetype)initWithCoder:(NSCoder *)decoder {

    if (self = [super init]) {
        _uid = [decoder decodeIntForKey:@"uid"];
        _name = [decoder decodeObjectForKey:@"name"];
        _weight = [decoder decodeIntForKey:@"weight"];
        _version = [decoder decodeIntForKey:@"version"];
        _followable = [decoder decodeBoolForKey:@"followable"];
        _followDays = [decoder decodeIntForKey:@"followDays"];
        _definition = [decoder decodeObjectForKey:@"definition"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeInt:self.uid forKey:@"uid"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeInt:self.weight forKey:@"weight"];
    [coder encodeInt:self.version forKey:@"version"];
    [coder encodeBool:self.followable forKey:@"followable"];
    [coder encodeInt:self.followDays forKey:@"followDays"];
    [coder encodeObject:self.definition forKey:@"definition"];
}

+ (instancetype _Nonnull)newWithData:(NSDictionary *)data {
    
    ReportType *reportType = [ReportType new];
    reportType.uid = [data[@"id"] intValue];
    reportType.name = data[@"name"];
    reportType.version = [data[@"version"] intValue];
    reportType.weight = [data[@"weight"] intValue];
    reportType.followable = [data[@"followable"] boolValue];
    reportType.followDays = [data[@"followDays"] intValue];
    reportType.definition = data[@"definition"];
    return reportType;
}

- (BOOL)isEqual:(id)object {
    
    SEL compareSEL = @selector(uid);
    if ([object respondsToSelector:compareSEL]) {
        int uid = [(ReportType *)object uid];
        return self.uid == uid;
        
    } else {
        return [super isEqual:object];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    
    ReportType *aCopy = [[ReportType allocWithZone:zone] init];
    aCopy.uid = self.uid;
    aCopy.name = self.name;
    aCopy.weight = self.weight;
    aCopy.version = self.version;
    aCopy.followable = self.followable;
    aCopy.followDays = self.followDays;
    aCopy.definition = self.definition;
    return aCopy;
}

- (NSArray<NSString *> * _Nonnull)mergeKeys {
    
    return @[ @"version"
              ,@"name"
              ,@"weight"
              ,@"followable"
              ,@"followDays"
              ,@"definition"
              ];
}

+ (NSComparator _Nonnull)weightComparator {
    
    NSComparator result = ^NSComparisonResult(ReportType * _Nonnull obj1, ReportType * _Nonnull obj2) {
        if (obj1.weight < obj2.weight) {
            return NSOrderedAscending;
        }
        if (obj1.weight > obj2.weight) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    };
    return result;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"ReportType[%i][%@][%i][%@]", self.uid, self.name, self.version, self.definition];
}

@end

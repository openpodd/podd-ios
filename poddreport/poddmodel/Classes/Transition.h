//
//  Transition.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Transition : NSObject
@property (assign, nonatomic) int from;
@property (assign, nonatomic) int to;
@property (assign, nonatomic) int order;
@property (copy, nonatomic) NSString *expression;
- (instancetype)initWithIdentifierFrom:(int)fromUid to:(int)toUid expression:(NSString *)expression;
@end

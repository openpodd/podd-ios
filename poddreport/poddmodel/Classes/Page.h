//
//  Page.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Question.h"

NS_ASSUME_NONNULL_BEGIN
@interface Page : NSObject

@property (assign, nonatomic) int uid;
@property (strong, nonatomic, nullable, readonly) NSMutableArray<Question *> *questions;
- (instancetype)initWithIdentifier:(int)uid;
- (void)addQuestion:(Question * _Nonnull)question;

@end
NS_ASSUME_NONNULL_END
//
//  QuestionItem.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/28/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionItem : NSObject
@property (copy, nonatomic, nonnull) NSString *text;
@property (copy, nonatomic, nonnull) NSString *identifier;
@property (copy, nonatomic, nullable) NSString *hiddenValue;
- (instancetype _Nonnull)initWithData:(NSDictionary * _Nonnull)data;
@end
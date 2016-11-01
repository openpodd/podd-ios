//
//  TransitionParser.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Transition.h"

@interface TransitionParser : NSObject
@end

@interface TransitionParser (Parse)
- (Transition *)parse:(NSDictionary *)transition;
@end
//
//  TransitionParser.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "TransitionParser.h"

@implementation TransitionParser

@end

@implementation TransitionParser (Parse)

- (Transition *)parse:(NSDictionary *)data {
    
    Transition *transition = [Transition new];
    transition.expression = data[@"expression"];
    transition.from = [data[@"from"] unsignedIntValue];
    transition.to = [data[@"to"] unsignedIntValue];
    transition.order = [data[@"order"] unsignedIntValue];
    return transition;
}

@end

//
//  NSOperationQueue+Timeout.m
//  poddreport
//
//  Created by Opendream-iOS on 2/23/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//
// http://stackoverflow.com/questions/25474752/nsoperationqueue-cancel-an-operation-after-a-timeout-given

#import "NSOperationQueue+Timeout.h"

@implementation NSOperationQueue (Timeout)

- (NSOperation *)addOperation:(NSOperation *)operation timeout:(NSTimeInterval)timeoutInSeconds timeoutBlock:(void (^)(void))timeoutBlock {
    
    [self addOperation:operation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (operation && ![operation isFinished]) {
            [operation cancel];
            if (timeoutBlock) {
                timeoutBlock();
            }
        }
    });
    return operation;
}

@end
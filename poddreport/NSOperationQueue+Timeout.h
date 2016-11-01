//
//  NSOperationQueue+Timeout.h
//  poddreport
//
//  Created by Opendream-iOS on 2/23/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (Timeout)
- (NSOperation *)addOperation:(NSOperation *)operation timeout:(NSTimeInterval)timeoutInSeconds timeoutBlock:(void (^)(void))timeoutBlock;
@end

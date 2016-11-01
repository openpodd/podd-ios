//
//  XCTestCase+PreloadData.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/14/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface XCTestCase_PreloadData : XCTestCase
- (id)preloadData:(Class)Parser withName:(NSString *)fileName;
@end

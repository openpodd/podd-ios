//
//  XCTestCase+PreloadData.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/14/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "XCTestCase+PreloadData.h"

@implementation XCTestCase_PreloadData

- (id)preloadData:(Class)Parser withName:(NSString *)fileName {
    
    [super setUp];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *mockupPath = [bundle pathForResource:fileName ofType:@"json"];
    NSData *stringData = [NSData dataWithContentsOfFile:mockupPath];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:NULL];
    NSDictionary *data = dictionary;
    id parser = [[Parser alloc] init];
    return [parser performSelector:@selector(parse:) withObject:data];
}

@end

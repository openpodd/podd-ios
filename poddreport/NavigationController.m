//
//  NavigationController.m
//  poddreport
//
//  Created by Opendream-iOS on 1/30/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "NavigationController.h"

@interface NavigationController ()

@end

@implementation NavigationController

- (UIStatusBarStyle)preferredStatusBarStyle {
        
    return [self.topViewController preferredStatusBarStyle];
}

@end

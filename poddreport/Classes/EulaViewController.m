//
//  EulaViewController.m
//  poddreport
//
//  Created by Opendream-iOS on 2/13/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "EulaViewController.h"

@interface EulaViewController ()
@property (strong, nonatomic, nonnull) NSURL *url;
@property (weak ,nonatomic, nullable) IBOutlet UIWebView *webView;
@end

@implementation EulaViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    self.url = [NSURL URLWithString:@"http://www.cmonehealth.org/privacy-policy/"];
    [self reload];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)reload {
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)openSafari:(id)sender {
    
    [[UIApplication sharedApplication] openURL:self.url];
}

@end

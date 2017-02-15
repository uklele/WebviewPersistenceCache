//
//  ViewController.m
//  WebviewPersistenceCache
//
//  Created by lmsgsendnilself on 2017/2/13.
//  Copyright © 2017年 p. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:webView];
    [webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://lmsgsendnilself.github.io/"]]];
}

@end

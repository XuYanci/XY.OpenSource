//
//  ViewController.m
//  WebViewJavascriptBridge
//
//  Created by Yanci on 2019/5/12.
//  Copyright © 2019 Yanci. All rights reserved.
//

#import "ViewController.h"
#import "WebViewJavascriptBridge.h"
@interface ViewController ()
@property WebViewJavascriptBridge* bridge;
@property IBOutlet WKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];
    
    [self.bridge registerHandler:@"ObjC Echo" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC Echo called with: %@", data);
        responseCallback(data);
    }];
    
    [self.bridge callHandler:@"JS Echo" data:nil responseCallback:^(id responseData) {
        NSLog(@"ObjC received response: %@", responseData);
    }];
}


@end

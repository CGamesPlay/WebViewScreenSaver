//
//  WebViewScreenSaver.h
//  WebViewScreenSaver
//
//  Created by Ryan Patterson on 3/16/12.
//  Copyright (c) 2012 Ryan Patterson. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <WebKit/WebKit.h>

@interface WebViewScreenSaver : ScreenSaverView
{
  @private
    WebView *webView_;
    WebView *configureWebView_;

    NSWindow *sheet_;
}

- (id)objectForInfoDictionaryKey:(NSString *)key;
- (void)setupPreferencesFor:(WebView *)webview;

@end

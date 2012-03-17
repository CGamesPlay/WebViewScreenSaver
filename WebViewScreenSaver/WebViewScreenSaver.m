//
//  WebViewScreenSaver.m
//  WebViewScreenSaver
//
//  Created by Ryan Patterson on 3/16/12.
//  Copyright (c) 2012 Ryan Patterson. All rights reserved.
//

#import "WebViewScreenSaver.h"

static NSString * const kBundleIdentifier = @"com.github.cgamesplay.WebViewScreenSaver";
static NSString * const kPrimaryURL = @"PrimaryURL";
static NSString * const kConfigureURL = @"ConfigureURL";
static NSString * const kConfigureFrame = @"ConfigureFrame";

@implementation WebViewScreenSaver

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
  self = [super initWithFrame:frame isPreview:isPreview];
  if (self) {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE
                                            forKey:@"WebKitDeveloperExtras"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    webView_ = [[WebView alloc] initWithFrame:[self bounds]];
    [webView_ setUIDelegate:self];
    [self addSubview:webView_];

    NSURL* baseURL =
      [[NSBundle bundleWithIdentifier:kBundleIdentifier] resourceURL];
    NSString* primaryURL = [self objectForInfoDictionaryKey:kPrimaryURL];
    NSURL* url = [NSURL URLWithString:primaryURL relativeToURL:baseURL];
    [webView_ setMainFrameURL:[url absoluteString]];
  }
  return self;
}

- (void)dealloc
{
  [webView_ release];
  [configureWebView_ release];
  [sheet_ release];
  [super dealloc];
}

- (BOOL)hasConfigureSheet
{
  return [self objectForInfoDictionaryKey:kConfigureURL] != nil;
}

- (NSWindow*)configureSheet
{
  NSArray* frameBounds = [self objectForInfoDictionaryKey:kConfigureFrame];
  NSRect frameRect = NSMakeRect(0, 0,
      [(NSNumber*)[frameBounds objectAtIndex:0] floatValue],
      [(NSNumber*)[frameBounds objectAtIndex:1] floatValue]);

  sheet_ = [[NSPanel alloc] init];
  [sheet_ setFrame:frameRect display:YES];

  WebView* webview = [[WebView alloc] init];
  [sheet_ setContentView:webview];
  [webview setUIDelegate:self];

  NSURL* baseURL =
    [[NSBundle bundleWithIdentifier:kBundleIdentifier] resourceURL];
  NSString* primaryURL = [self objectForInfoDictionaryKey:kConfigureURL];
  NSURL* url = [NSURL URLWithString:primaryURL relativeToURL:baseURL];
  [webview setMainFrameURL:[url absoluteString]];

  return sheet_;
}

- (id)objectForInfoDictionaryKey:(NSString *)key
{
  NSDictionary *infoDictionary =
    [[NSBundle bundleWithIdentifier:kBundleIdentifier] infoDictionary];
  return [infoDictionary objectForKey:key];
}

- (void)webViewClose:(WebView*)sender
{
  [[NSApplication sharedApplication] endSheet:sheet_];
  [sheet_ release];
  sheet_ = nil;
  [configureWebView_ release];
  configureWebView_ = nil;
}

@end

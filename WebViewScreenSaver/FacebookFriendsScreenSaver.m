//
//  WebViewScreenSaver.m
//  WebViewScreenSaver
//
//  Created by Ryan Patterson on 3/16/12.
//  Copyright (c) 2012 Ryan Patterson. All rights reserved.
//

#import "FacebookFriendsScreenSaver.h"
#include <objc/message.h>

static NSString * const kBundleIdentifier = @"com.github.cgamesplay.FacebookFriendsScreenSaver";
static NSString * const kPrimaryURL = @"PrimaryURL";
static NSString * const kConfigureURL = @"ConfigureURL";
static NSString * const kConfigureFrame = @"ConfigureFrame";
static NSString * const kDebugMode = @"DebugMode";
// WebView does not allow configuring Web SQL Database path, so we'll lock this
// just for consistency.
static NSString * const kLocalStorageDatabasePath = @"~/Library/WebKit/LocalStorage";

@implementation FacebookFriendsScreenSaver

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
  self = [super initWithFrame:frame isPreview:isPreview];
  if (self) {
    webView_ = [[WebView alloc] initWithFrame:[self bounds]];
    [self setupPreferencesFor:webView_];
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

- (BOOL)isDebugMode
{
  NSNumber* debugMode = [self objectForInfoDictionaryKey:kDebugMode];
  return [debugMode boolValue];
}

- (NSView *)hitTest:(NSPoint)aPoint
{
  if (![self isDebugMode]) {
    return nil;
  }

  return [super hitTest:aPoint];
}

- (NSView *)nextKeyView
{
  if (![self isDebugMode]) {
    return nil;
  }

  return [super nextKeyView];
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

  configureWebView_ = [[WebView alloc] init];
  [self setupPreferencesFor:configureWebView_];
  [sheet_ setContentView:configureWebView_];
  [configureWebView_ setUIDelegate:self];

  NSURL* baseURL =
    [[NSBundle bundleWithIdentifier:kBundleIdentifier] resourceURL];
  NSString* primaryURL = [self objectForInfoDictionaryKey:kConfigureURL];
  NSURL* url = [NSURL URLWithString:primaryURL relativeToURL:baseURL];
  [configureWebView_ setMainFrameURL:[url absoluteString]];

  return sheet_;
}

- (id)objectForInfoDictionaryKey:(NSString *)key
{
  NSDictionary *infoDictionary =
    [[NSBundle bundleWithIdentifier:kBundleIdentifier] infoDictionary];
  return [infoDictionary objectForKey:key];
}

- (void)setupPreferencesFor:(WebView *)webview
{
  WebPreferences *preferences = webview.preferences;
  objc_msgSend(preferences, @selector(setLocalStorageEnabled:), YES);
  objc_msgSend(preferences, @selector(_setLocalStorageDatabasePath:),
    kLocalStorageDatabasePath);

  objc_msgSend(preferences, @selector(setDeveloperExtrasEnabled:),
    [self isDebugMode]);
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

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
    [webView_ setFrameLoadDelegate:self];

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

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
  if (sender == webView_) {
    [self addSubview:webView_];
  }
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
  NSRect windowRect = NSMakeRect(10.0f, 10.0f, 800.0f, 600.0f);
  NSUInteger styleMask = NSResizableWindowMask | NSClosableWindowMask | NSTitledWindowMask;
  NSWindow *newWindow = [[NSWindow alloc] initWithContentRect:windowRect
                                                    styleMask:styleMask
                                                      backing:NSBackingStoreBuffered
                                                        defer:NO];
  [newWindow retain];

  WebView *newWebView = [[WebView alloc] initWithFrame:[newWindow.contentView frame]];
  [newWindow setContentView:newWebView];

  [newWebView setUIDelegate:self];
  [newWebView.mainFrame loadRequest:request];

  return newWebView;
}

- (void)webViewShow:(WebView *)sender
{
  if (sender == configureWebView_ || sender == webView_) {
    return;
  }
  [sender.window makeKeyAndOrderFront:self];
}

- (void)webViewClose:(WebView*)sender
{
  if (sender == configureWebView_) {
    [[NSApplication sharedApplication] endSheet:sheet_];
    [sheet_ release];
    sheet_ = nil;
    [configureWebView_ release];
    configureWebView_ = nil;
    [webView_ reload:self];

  } else if (sender == webView_) {
    // Silly screen saver, you can't close yourself like that (actually this
    // never happens because there's no UIDelegate, but future-proofing...)

  } else {
    // Must be a new window we created. Free the window.
    [sender.window close];
    [sender.window release];
  }
}

@end

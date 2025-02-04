//
// --------------------------------------------------------------------------
// UpdateWindow.m
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2019
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import "UpdateWindow.h"
#import "Updater.h"
#import "MoreSheet.h"
#import "AppDelegate.h"
#import <WebKit/WebKit.h>
#import "Utility_App.h"

@interface UpdateWindow ()

@end

@implementation UpdateWindow

// TODO: Make this variable hold the actual UpdateWindow instance instead of the NSWindow instance. The UpdateWindow instance is a window controller and therefore has a _window attribute which holds the same value as this currently does.
static NSWindow *_instance;
+ (NSWindow *)instance {
    return _instance;
}
+ (void)setInstance:(NSWindow *)new {
    _instance = new;
}

- (instancetype)init
{
    NSLog(@"Initializing Update Window");
    self = [super init];
    if (self) {
        UpdateWindow.instance = self;
        self = [self initWithWindowNibName:@"UpdateWindow"];
    }
    return self;
}

- (IBAction)skip:(id)sender {
    [Updater skipAvailableVersion];
    [self close];
}
- (IBAction)update:(id)sender {
    [Updater update];
    [self close];
}

- (void)windowWillClose:(NSNotification *)notification {
    
}

- (void)themeChanged:(NSNotification *)ntf {
    NSLog(@"Theme Changed!");
    [self.window performClose:NULL];
}

- (void)startWithUpdateNotes:(NSURL *)updateNotesLocation {
    
    NSLog(@"Starting update window with update notes at: %@", updateNotesLocation.path);
    [super windowDidLoad];
    
    // Disable resize button
    [[self.window standardWindowButton:NSWindowZoomButton] setEnabled:NO];
    
    // React to darkmode/lightmode change
    [NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(themeChanged:) name:@"AppleInterfaceThemeChangedNotification" object: nil];
    
    // Create webview
    [self createWebviewWithURL:updateNotesLocation];
    
    // Set size
    NSRect frame = self.window.frame;
    frame.size = CGSizeMake(330, 220);
    [self.window setFrame:frame display:NO];
    
    // Center update window on main window
    [Utility_App centerWindow:self.window atPoint:[Utility_App getCenterOfRect:AppDelegate.mainWindow.frame]];
    [Utility_App openWindowWithFadeAnimation:self.window fadeIn:YES fadeTime:0.0];
    
    
    
}

- (void)createWebviewWithURL:(NSURL *)updateNotesURL {
    
//    updateNotesURL = [NSURL fileURLWithPath:@"/Users/Noah/Desktop/updatenotes"];
    
    [self.window setFrame:NSMakeRect(0, 0, 440, 462) display:NO animate:NO];
    NSRect WKFrm = NSMakeRect(80, 57, 340, 363); // (20, 57, 400, 332/363)
    
    WKWebViewConfiguration *WKConf = [[WKWebViewConfiguration alloc] init];
    [WKConf.userContentController addScriptMessageHandler:(id<WKScriptMessageHandler>)self name:@"THELARGEBOTTOM"];
    
    WKWebView *wv = [[WKWebView alloc] initWithFrame:WKFrm configuration:WKConf];
    [wv setNavigationDelegate:self];

    [wv loadFileURL:[updateNotesURL URLByAppendingPathComponent:@"index.html" isDirectory:NO] allowingReadAccessToURL:updateNotesURL];
    
    wv.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.window.contentView addSubview:wv];

    wv.layer.cornerRadius = 5;
    wv.layer.masksToBounds = YES;

    [wv setValue:@(NO) forKey:@"drawsBackground"];
    [wv display];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    NSLog(@"Update window webview finished navigation");
    
    // Change style according to system appearance
    if (@available(macOS 10.14, *)) {
        
        NSLog(@"Running macOS 10.14+. Setting webview style according to system appearance.");
        
        // Find appropriate css file path
        
        NSString *cssFileDir = @"Aqua";
        if (NSApplication.sharedApplication.effectiveAppearance == [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua]) {
            cssFileDir = @"DarkAqua";
        }
        // Set webview to css file
        
        NSLog(@"Setting webview css to: %@", cssFileDir);
        
        NSString *jsDir = [NSString stringWithFormat:@"document.getElementById('styleSheetId').href='./%@.css'", cssFileDir];
        [webView evaluateJavaScript:jsDir completionHandler:^(id response, NSError *error) {
            NSLog(@"Setting css response: %@",(NSString *)response);
            NSLog(@"Setting css error: %@",error);
        }];
        
        // Get webview title
        // Is this necessary? I think this is residue from when we wanted to present the title natively instead of in the webview
        
        NSLog(@"Getting html h1");
        
        [webView evaluateJavaScript:@"document.getElementsByTagName('h1')[0].textContent" completionHandler:^(id response, NSError *error) {
            NSLog(@"Getting h1 response: %@",(NSString *)response);
            NSLog(@"Getting h1 error: %@",error);
        }];
        
        // Make scrollbar dark when darkmode is enabled (v this doesn't work)
        webView.enclosingScrollView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
        
    } else {
        NSLog(@"Running macOS 10.13 or lower. Not necessary to set webview style to system appearance, because there is no darkmode");
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSLog(@"Update window webview received navigation action: %@", navigationAction);
    
    if (navigationAction.navigationType == -1) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    else {
        decisionHandler(WKNavigationActionPolicyCancel);
        [[NSWorkspace sharedWorkspace] openURL:navigationAction.request.URL];
    }
}

@end

//
// --------------------------------------------------------------------------
// AddWindowController.m
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2021
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import "AddWindowController.h"
#import "AppDelegate.h"
#import "MessagePort_App.h"
#import "RemapTableController.h"
#import "Utility_App.h"
#import "SharedUtility.h"
#import "MFNotificationOverlayController.h"

@interface AddWindowController ()
@property (weak) IBOutlet NSBox *addField;
@property (weak) IBOutlet NSImageView *plusIconView;
@end

@implementation AddWindowController

// Init

static AddWindowController *_instance;
+ (void)initialize {
    _instance = [[AddWindowController alloc] initWithWindowNibName:@"AddWindow"];
}
- (void)windowDidLoad {
    [super windowDidLoad];
    // Setup tracking area
    NSTrackingArea *addTrackingArea = [[NSTrackingArea alloc] initWithRect:self.addField.frame options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingEnabledDuringMouseDrag owner:self userInfo:nil];
    // (Well I can't use ad tracking cause I claim to be privacy focused on the website, but at least I can use add tracking! Hmu if you can think of a way to monetize that.)
    [self.window.contentView addTrackingArea:addTrackingArea];
}

// UI callbacks

- (IBAction)cancelButton:(id)sender {
    [AddWindowController end];
}
- (void)mouseEntered:(NSEvent *)event {
    NSLog(@"MOSUE ENTERED ADD FIELD");
    [AddWindowController enableAddFieldHoverEffect:YES];
    [MessagePort_App sendMessageToHelper:@"enableAddMode"];
}
- (void)mouseExited:(NSEvent *)event {
    NSLog(@"MOSUE EXTITSED ADD FIELD");
    [AddWindowController enableAddFieldHoverEffect:NO];
    [MessagePort_App sendMessageToHelper:@"disableAddMode"];
}

// Interface

+ (void)begin {
    [AppDelegate.mainWindow beginSheet:_instance.window completionHandler:nil];
    
    // Testing
    NSAttributedString *message = [[NSAttributedString alloc] initWithString:@"AddddDd"];
    NSView *notif = [MFNotificationOverlayController getNotificationWithMessage:message];
    notif.frame = NSMakeRect(-20, -20, 300, 100);
    [_instance.window.contentView addSubview:notif];
    _instance.window.contentView.wantsLayer = YES;
    _instance.window.contentView.layer.masksToBounds = NO;
}
+ (void)end {
    [AppDelegate.mainWindow endSheet:_instance.window];
}
+ (void)handleReceivedAddModeFeedbackFromHelperWithPayload:(NSDictionary *)payload {
    // Tint plus icon to give visual feedback
    NSImageView *plusIconViewCopy;
//    if (NO) {
    if (@available(macOS 10.14, *)) {
        plusIconViewCopy = (NSImageView *)[SharedUtility deepCopyOf:_instance.plusIconView];
        [_instance.plusIconView.superview addSubview:plusIconViewCopy];
        plusIconViewCopy.alphaValue = 0.0;
        plusIconViewCopy.contentTintColor = NSColor.controlAccentColor;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            NSAnimationContext.currentContext.duration = 0.2;
//            _instance.plusIconView.animator.alphaValue = 0.0;
            plusIconViewCopy.animator.alphaValue = 0.3;
            [NSThread sleepForTimeInterval:NSAnimationContext.currentContext.duration];
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self wrapUpAddModeFeedbackHandlingWithPayload:payload andPlusIconViewCopy:plusIconViewCopy];
        });
    } else {
        [self wrapUpAddModeFeedbackHandlingWithPayload:payload andPlusIconViewCopy:plusIconViewCopy];
    }
}
+ (void)wrapUpAddModeFeedbackHandlingWithPayload:(NSDictionary * _Nonnull)payload andPlusIconViewCopy:(NSImageView *)plusIconViewCopy {
    // Dismiss sheet
    [self end];
    // Send payload to RemapTableController
    //      The payload is an almost finished remapsTable (aka RemapTableController.dataModel) entry with the kMFRemapsKeyEffect key missing
    [((RemapTableController *)AppDelegate.instance.remapsTable.delegate) addRowWithHelperPayload:(NSDictionary *)payload];
    // Reset plus image tint
    if (@available(macOS 10.14, *)) {
        plusIconViewCopy.alphaValue = 0.0;
        [plusIconViewCopy removeFromSuperview];
        _instance.plusIconView.alphaValue = 1.0;
    }
}

+ (void)enableAddFieldHoverEffect:(BOOL)enable {
    // None of this works
    NSBox *af = _instance.addField;
    NSView *afSub = _instance.addField.subviews[0];
    if (enable) {
        afSub.wantsLayer = YES;
        af.wantsLayer = YES;
        af.layer.masksToBounds = NO;
        
        // Shadow (doesn't work withough setting background color)
//        NSShadow *shadow = [[NSShadow alloc] init];
//        shadow.shadowColor = NSColor.blackColor;
//        shadow.shadowOffset = NSZeroSize;
//        shadow.shadowBlurRadius = 10;
//        afSub.shadow = shadow;
        
        // Focus ring
        afSub.focusRingType = NSFocusRingTypeDefault;
        [afSub becomeFirstResponder];
        af.focusRingType = NSFocusRingTypeDefault;
        [af becomeFirstResponder];
    } else {
        // Shadow
        afSub.shadow = nil;
        afSub.layer.shadowOpacity = 0.0;
        afSub.layer.backgroundColor = nil;
        // Focus ring
        [afSub resignFirstResponder];
        
    }
}
@end


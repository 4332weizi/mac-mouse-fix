//
// --------------------------------------------------------------------------
// RemapUtility.m
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2020
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import "Utility_Transformation.h"
#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <ApplicationServices/ApplicationServices.h>
#import "CGSPrivate.h"
#import "SharedUtility.h"

@implementation Utility_Transformation

+ (void)hideMousePointer:(BOOL)B {
    
    if (B) {
        void CGSSetConnectionProperty(int, int, CFStringRef, CFBooleanRef);
        int _CGSDefaultConnection(void);
        CFStringRef propertyString;

        // Hack to make background cursor setting work
        propertyString = CFStringCreateWithCString(NULL, "SetsCursorInBackground", kCFStringEncodingUTF8);
        CGSSetConnectionProperty(_CGSDefaultConnection(), _CGSDefaultConnection(), propertyString, kCFBooleanTrue);
        CFRelease(propertyString);
        // Hide the cursor and wait
        CGDisplayHideCursor(kCGDirectMainDisplay);
//        pause();
    } else {
        CGDisplayShowCursor(kCGDirectMainDisplay);
    }
}

#pragma mark - Button clicks

+ (void)postMouseButtonClicks:(MFMouseButtonNumber)button nOfClicks:(int64_t)nOfClicks {
    
    CGEventTapLocation tapLoc = kCGSessionEventTap;
    
    CGPoint mouseLoc = Utility_Transformation.CGMouseLocationWithoutEvent;
    CGEventType eventTypeDown = [SharedUtility CGEventTypeForButtonNumber:button isMouseDown:YES];
    CGEventType eventTypeUp = [SharedUtility CGEventTypeForButtonNumber:button isMouseDown:NO];
    CGMouseButton buttonCG = [SharedUtility CGMouseButtonFromMFMouseButtonNumber:button];
    
    CGEventRef buttonDown = CGEventCreateMouseEvent(NULL, eventTypeDown, mouseLoc, buttonCG);
    CGEventRef buttonUp = CGEventCreateMouseEvent(NULL, eventTypeUp, mouseLoc, buttonCG);
    
    int clickLevel = 1;
    while (clickLevel <= nOfClicks) {
        
        CGEventSetIntegerValueField(buttonDown, kCGMouseEventClickState, clickLevel);
        CGEventSetIntegerValueField(buttonUp, kCGMouseEventClickState, clickLevel);
        
        CGEventPost(tapLoc, buttonDown);
        CGEventPost(tapLoc, buttonUp);
        
        clickLevel++;
    }
    
    CFRelease(buttonDown);
    CFRelease(buttonUp);
}
+ (void)postMouseButton:(MFMouseButtonNumber)button down:(BOOL)down {
    CGEventTapLocation tapLoc = kCGSessionEventTap;
    
    CGPoint mouseLoc = Utility_Transformation.CGMouseLocationWithoutEvent;
    CGEventType eventTypeDown = [SharedUtility CGEventTypeForButtonNumber:button isMouseDown:down];
    CGMouseButton buttonCG = [SharedUtility CGMouseButtonFromMFMouseButtonNumber:button];
    
    CGEventRef event = CGEventCreateMouseEvent(NULL, eventTypeDown, mouseLoc, buttonCG);
    CGEventSetIntegerValueField(event, kCGMouseEventClickState, 1);
    
    CGEventPost(tapLoc, event);
    CFRelease(event);
}

// Methods for obtaining effective remaps

/// Returns a block
///     - Which takes 2 arguments: `remaps` and `activeModifiers`
///     - The block takes the default remaps (with an empty precondition) and overrides it with the remappings defined for a precondition of `activeModifiers`.
+ (MFEffectiveRemapsMethod)effectiveRemapsMethod_Override {
    
    return ^NSDictionary *(NSDictionary *remaps, NSDictionary *activeModifiers) {
        NSDictionary *effectiveRemaps = remaps[@{}];
        NSDictionary *remapsForActiveModifiers = remaps[activeModifiers];
        if ([activeModifiers isNotEqualTo:@{}]) {
            effectiveRemaps = [SharedUtility dictionaryWithOverridesAppliedFrom:[remapsForActiveModifiers copy] to:effectiveRemaps]; // Why do we do ` - copy` here?
        }
        return effectiveRemaps;
    };
}

+ (CGPoint)CGMouseLocationWithoutEvent {
    CGEventRef locEvent = CGEventCreate(NULL);
    CGPoint mouseLoc = CGEventGetLocation(locEvent);
    CFRelease(locEvent);
    return mouseLoc;
}
+ (CGEventFlags)CGModifierFlagsWithoutEvent {
    CGEventRef flagEvent = CGEventCreate(NULL);
    CGEventFlags flags = CGEventGetFlags(flagEvent);
    CFRelease(flagEvent);
    return flags;
}

@end

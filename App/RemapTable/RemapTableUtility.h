//
// --------------------------------------------------------------------------
// RemapTableUtility.h
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2021
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Constants.h"


NS_ASSUME_NONNULL_BEGIN

@interface RemapTableUtility : NSObject

+ (MFMouseButtonNumber)triggerButtonForRow:(NSUInteger)row tableViewDataModel:(NSArray *)dataModel;
+ (NSPopUpButton *)getPopUpButtonAtRow:(NSUInteger)popUpRow fromTableView:(NSTableView *)tv;

@end

NS_ASSUME_NONNULL_END

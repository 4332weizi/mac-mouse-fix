//
// --------------------------------------------------------------------------
// NSAttributedString+Additions.h
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2021
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (Additions)
- (NSAttributedString *)attributedStringByAddingBaseAttributes:(NSDictionary *)baseAttributes;
- (NSAttributedString *)attributedStringByAddingLinkWithURL:(NSURL *)linkURL forSubstring:(NSString *)substring;
- (NSAttributedString *)attributedStringByAddingBoldForSubstring:(NSString *)subStr;
- (NSAttributedString *)attributedStringByAddingItalicForSubstring:(NSString *)subStr;
- (NSSize)sizeAtMaxWidth:(CGFloat)maxWidth;
- (CGFloat)heightAtWidth:(CGFloat)width;
- (CGFloat)width;
+ (NSAttributedString *)hyperlinkFromString:(NSString *)inString withURL:(NSURL *)aURL;
@end

NS_ASSUME_NONNULL_END

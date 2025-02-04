//
// --------------------------------------------------------------------------
// NSAttributedString+Additions.m
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2021
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import "NSAttributedString+Additions.h"
#import <Cocoa/Cocoa.h>

@implementation NSAttributedString (Additions)

/// Create string by adding values from `baseAttributes`, without overriding any of the attributes set for `self`
- (NSAttributedString *)attributedStringByAddingBaseAttributes:(NSDictionary *)baseAttributes {
    
    NSMutableAttributedString *s = self.mutableCopy;
    
    [s addAttributes:baseAttributes range:NSMakeRange(0, s.length)]; // Base attributes will override string attributes
    [self enumerateAttributesInRange:NSMakeRange(0, s.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        [s addAttributes:attrs range:range];
    }]; // Override base attributes with original string attributes to undo overrides of original string attributes
    return s.copy;
}

- (NSAttributedString *)attributedStringByAddingLinkWithURL:(NSURL *)linkURL forSubstring:(NSString *)substring {
    
    NSMutableAttributedString *str = self.mutableCopy;
    
     NSRange foundRange = [str.mutableString rangeOfString:substring];
     NSAttributedString *linkString = [NSAttributedString hyperlinkFromString:substring withURL:linkURL];
     [str replaceCharactersInRange:foundRange withAttributedString:linkString];
    
     return str;
}

- (NSAttributedString *)attributedStringByAddingSymbolicFontTraits:(NSFontDescriptorSymbolicTraits)traits forSubstring:(NSString *)subStr {
    NSDictionary *originalAttributes = [self attributesAtIndex:0 effectiveRange:nil];
    NSFont *originalFont = originalAttributes[NSFontAttributeName];
    if (originalFont == nil) {
        originalFont = [NSFont systemFontOfSize:NSFont.systemFontSize];
    }
    NSFontDescriptor *newFontDescriptor = [originalFont.fontDescriptor fontDescriptorWithSymbolicTraits:traits];
    NSFont *newFont = [NSFont fontWithDescriptor:newFontDescriptor size:originalFont.pointSize];
    
    NSRange subStrRange = [self.string rangeOfString:subStr];
    
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] initWithAttributedString:self];
    [ret addAttribute:NSFontAttributeName value:newFont range:subStrRange];
    
    return ret;
}

- (NSAttributedString *)attributedStringByAddingBoldForSubstring:(NSString *)subStr {
  
    NSFontDescriptorSymbolicTraits traits = NSFontDescriptorTraitBold;
    
    return [self attributedStringByAddingSymbolicFontTraits:traits forSubstring:subStr];
    
//    NSFont *boldFont = [NSFont boldSystemFontOfSize:NSFont.systemFontSize];
//    NSRange subStrRange = [self.string rangeOfString:subStr];
//
//    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] initWithAttributedString:self];
//    [ret addAttribute:NSFontAttributeName value:boldFont range:subStrRange];
//    return ret;
}

- (NSAttributedString *)attributedStringByAddingItalicForSubstring:(NSString *)subStr {
    
    NSFontDescriptorSymbolicTraits traits = NSFontDescriptorTraitItalic;
    
    return [self attributedStringByAddingSymbolicFontTraits:traits forSubstring:subStr];
}

- (NSSize)sizeAtMaxWidth:(CGFloat)maxWidth {
    
    CGFloat width = self.width <= maxWidth ? self.width : maxWidth;
    CGFloat height = [self heightAtWidth:width];
    
    return NSMakeSize(width, height);
}

// Derived from https://stackoverflow.com/questions/2282629/how-to-get-height-for-nsattributedstring-at-a-fixed-width/2460091#2460091
// 
- (CGFloat)heightAtWidth:(CGFloat)width {
    
    // Method 1
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:
        NSMakeSize(width, FLT_MAX)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [layoutManager glyphRangeForTextContainer:textContainer];
    CGFloat result1 = [layoutManager usedRectForTextContainer:textContainer].size.height;
        
    // Method 2
    NSRect bounds = [self boundingRectWithSize:NSMakeSize(width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading];
    CGFloat result2 = bounds.size.height; //CGRectIntegral(bounds).size.height;
    
    // ---
#if DEBUG
//    NSLog(@"NSAttributedString height for width: %f - layoutManager: %f, boundingRect: %f", width, result1, result2);
#endif
    return ceil(result2);
    // ^ Using `result1` has multiline NSTextFields clipping their last line. `result2` seems to work perfectly.
}

- (CGFloat)width {
    // Method 1
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:
        NSMakeSize(FLT_MAX, FLT_MAX)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [layoutManager glyphRangeForTextContainer:textContainer];
    CGFloat result1 = [layoutManager usedRectForTextContainer:textContainer].size.width;
    
    return ceil(result1);
}

/// Copy pasted this from somewhere
+ (NSAttributedString *)hyperlinkFromString:(NSString *)inString withURL:(NSURL *)aURL {
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:inString.mutableCopy];
    NSRange range = NSMakeRange(0, attrString.length);
 
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName value:aURL.absoluteString range:range];
 
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
 
    // next make the text appear with an underline
    [attrString addAttribute:
            NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];
 
    [attrString endEditing];
 
    return attrString;
}

@end

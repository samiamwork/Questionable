//
//  TIPTextContainer.h
//  ATSUITest
//
//  Created by Nur Monson on 5/13/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum _TIPTextAlignment {
	kTIPTextAlignmentLeft,
	kTIPTextAlignmentRight,
	kTIPTextAlignmentCenter
} TIPTextAlignment;

@interface TIPTextContainer : NSObject {
	TIPTextAlignment alignment;

	BOOL       _truncate;
	CTFontRef  _font;
	CGColorRef _color;
	NSString*  _fontName;
	CGFloat    _fontSize;
	CGFloat    _lineWidth;
	CTTextAlignment _alignment;
	CFMutableAttributedStringRef _attributedString;
}

+ (id)containerWithString:(NSString *)aString;
+ (id)containerWithString:(NSString *)aString color:(NSColor *)aColor fontName:(NSString *)theFontName;

- (void)setFontWithName:(NSString*)fontName;
- (void)setFontSize:(float)theSize;
- (CGFloat)fontSize;
- (void)setAlignment:(TIPTextAlignment)newAlignment;
- (void)setColor:(NSColor *)aColor;
- (void)setText:(NSString *)theText;
- (void)setTruncates:(BOOL)shouldTruncate;
- (void)setLineWidth:(CGFloat)lineWidth;
- (NSUInteger)lineCount;
- (NSSize)containerSize;

- (void)fitTextInRect:(NSRect)rect;
- (void)drawTextInRect:(NSRect)rect inContext:(CGContextRef)ctx;

@end

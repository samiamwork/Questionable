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
	UniChar *textBuffer;
	unsigned textLength;
	ItemCount lineCount;
	float fontSize;
	float lineWidth;
	NSString *fontName;
	TIPTextAlignment alignment;
	ATSUTextMeasurement leading;

	ATSUStyle defaultStyle;
	ATSUTextLayout defaultLayout;
	
	ATSUTextMeasurement firstAscent;
	ATSUTextMeasurement totalHeight;
	
	ATSUTextMeasurement *lineHeights;
	UniCharArrayOffset *endOfLines;
	
	BOOL _fitInRect;
	BOOL _widthDirty;
}

+ (id)containerWithString:(NSString *)aString;
+ (id)containerWithString:(NSString *)aString color:(NSColor *)aColor fontName:(NSString *)theFontName;

- (void)setWidth:(float)width;
- (void)setFitInRect:(BOOL)willFitInRect;
- (BOOL)fitInRect;
- (void)setFont:(NSFont *)newFont;
- (void)setFontWithName:(NSString *)newFontName;
- (void)setFontSize:(float)theSize;
- (float)fontSize;
- (void)setLeading:(float)theLeading;
- (void)setAlignment:(TIPTextAlignment)newAlignment;
- (void)setColor:(NSColor *)aColor;
- (void)setText:(NSString *)theText;
- (void)setShadowWithOffset:(NSSize)anOffset color:(NSColor *)aColor blur:(float)blur;

- (unsigned int)lineCount;
- (NSSize)containerSize;

- (void)fitTextInRect:(NSRect)rect;
- (void)drawTextInRect:(NSRect)rect inContext:(CGContextRef)cxt;

@end

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
	
}

+ (id)containerWithString:(NSString *)aString;
+ (id)containerWithString:(NSString *)aString color:(NSColor *)aColor fontName:(NSString *)theFontName;

- (void)setWidth:(float)width;
- (void)setFontWithName:(NSString *)newFontName;
- (void)setFontSize:(float)theSize;
- (void)setLeading:(float)theLeading;
- (void)setAlignment:(TIPTextAlignment)newAlignment;
- (void)setColor:(NSColor *)aColor;
- (void)setText:(NSString *)theText;

- (NSSize)containerSize;

-(void)drawTextInRect:(NSRect)rect inContext:(CGContextRef)cxt;

@end

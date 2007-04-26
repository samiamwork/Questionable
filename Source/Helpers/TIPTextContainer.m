//
//  TIPTextContainer.m
//  ATSUITest
//
//  Created by Nur Monson on 5/13/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TIPTextContainer.h"

#define ERR_PREFIX "TIPATSUI container: "

@implementation TIPTextContainer

int allocateTextArrays( ATSUTextMeasurement **heights, UniCharArrayOffset **offsets, int numberOfElements )
{
	if( *heights ) {
		free(*heights);
		*heights = NULL;
	}
	
	*heights = (ATSUTextMeasurement *)malloc( numberOfElements*(sizeof(ATSUTextMeasurement)+sizeof(UniCharArrayOffset)) );
	if( !*heights )
		return 0;
	
	*offsets = (UniCharArrayOffset *)((char*)*heights + (numberOfElements*sizeof(ATSUTextMeasurement)));
	return 1;
}

int deallocateTextArrays( ATSUTextMeasurement **heights, UniCharArrayOffset **offsets )
{
	if(*heights)
		free(*heights);
	
	*heights = NULL;
	*offsets = NULL;
	
	return 1;
}

- (id)init
{
	if( (self = [super init]) ) {
		textBuffer = NULL;
		textLength = 0;
		lineCount = 0;
		fontSize  = 0.0f;
		leading = FloatToFixed(0.0f);
		lineWidth = 0.0f;
		fontName = nil;
		
		lineHeights = NULL;
		endOfLines = NULL;
		
		OSStatus status = noErr;
		
		status = ATSUCreateStyle(&defaultStyle);
		if(status != noErr)
			printf(ERR_PREFIX "could not create style!\n");
		
		status = ATSUCreateTextLayout(&defaultLayout);
		if(status != noErr)
			printf("could not create text layout!\n");
		
		[self setText:@"Text not set!"];
		[self setAlignment:kTIPTextAlignmentCenter];
		[self setFontSize:12.0f];
		
		ATSUSetTransientFontMatching(defaultLayout, true);
		
		_fitInRect = NO;
		_widthDirty = YES;
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	if(textBuffer)
		free(textBuffer);
	if(fontName)
		[fontName release];
	
	deallocateTextArrays( &lineHeights, &endOfLines);
	
	ATSUDisposeStyle(defaultStyle);
	ATSUDisposeTextLayout(defaultLayout);
	
}

- (void)recalculateLineHeights
{
	OSStatus status;
	unsigned thisLine;
	ATSUTextMeasurement ascent;
	ATSUTextMeasurement descent;
	
	totalHeight = 0;
	// now calculate the line heights
	for( thisLine=0; thisLine<lineCount; thisLine++) {
		
		status = ATSUGetLineControl(defaultLayout, endOfLines[thisLine], kATSULineAscentTag, sizeof(ATSUTextMeasurement), &ascent, NULL);
		status = ATSUGetLineControl(defaultLayout, endOfLines[thisLine], kATSULineDescentTag, sizeof(ATSUTextMeasurement), &descent, NULL);
		lineHeights[thisLine] = ascent + descent + leading;
		
		if( thisLine==0 )
			firstAscent = ascent;
		totalHeight += lineHeights[thisLine];
	}
	
	// correct the total height so that it reflects the true height (leading is not part of the text).
	totalHeight -= leading;
}

#pragma mark creation

+ (id)containerWithString:(NSString *)aString
{
	id newContainer = [[[self class] alloc] init];
	
	[newContainer setText:aString];
	[newContainer setColor:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
	
	return [newContainer autorelease];
}
+ (id)containerWithString:(NSString *)aString color:(NSColor *)aColor fontName:(NSString *)theFontName
{
	id newContainer = [[[self class] alloc] init];
	
	[newContainer setText:aString];
	[newContainer setColor:aColor];
	[newContainer setFontWithName:theFontName];
	
	return [newContainer autorelease];
}

/*==================*/
#pragma mark setters
/*==================*/

- (void)setWidth:(float)width
{
	OSStatus status;
	CFIndex strLength = textLength;
	
	if( lineWidth == width && !_widthDirty )
		return;
	
	lineWidth = width;
	
	ATSUAttributeTag layoutTags[] = {kATSULineWidthTag};
	ByteCount layoutSizes[] = {sizeof(ATSUTextMeasurement)};
	ATSUTextMeasurement myLineWidth = FloatToFixed(width);
	ATSUAttributeValuePtr layoutValues[] = {&myLineWidth};
	
	status = ATSUSetLayoutControls(defaultLayout, 1, layoutTags, layoutSizes, layoutValues);
	
	ATSUClearSoftLineBreaks(defaultLayout,kATSUFromTextBeginning,kATSUToTextEnd);
	status = ATSUBatchBreakLines(defaultLayout,kATSUFromTextBeginning,kATSUToTextEnd, FloatToFixed(width),NULL);
	
	endOfLines = NULL;
	lineHeights = NULL;
	status = ATSUGetSoftLineBreaks(defaultLayout, kATSUFromTextBeginning, kATSUToTextEnd, 0, NULL, &lineCount);
	lineCount += 1;
	allocateTextArrays( &lineHeights, &endOfLines, lineCount + 1);
	
	endOfLines[0] = 0;
	status = ATSUGetSoftLineBreaks(defaultLayout, kATSUFromTextBeginning, kATSUToTextEnd, lineCount, &endOfLines[1], &lineCount);
	lineCount += 1;
	endOfLines[lineCount] = strLength;
	
	[self recalculateLineHeights];
	
	_widthDirty = NO;
}

- (void)setFitInRect:(BOOL)willFitInRect
{
	_fitInRect = willFitInRect;
}
- (BOOL)fitInRect
{
	return _fitInRect;
}

- (void)setFont:(NSFont *)newFont
{
	if( newFont == nil )
		return;
	
	[self setFontWithName:[newFont fontName]];
}

- (void)setFontWithName:(NSString *)newFontName
{
	if( newFontName == nil )
		return;
	
	OSStatus status;
	
	ATSUFontID newFontID;
	ATSUAttributeTag styleTags[] = {kATSUFontTag};
	ByteCount styleSizes[] = {sizeof(ATSUFontID)};
	ATSUAttributeValuePtr styleValues[] = {&newFontID};
	
	ATSUFindFontFromName([newFontName cStringUsingEncoding:NSUTF8StringEncoding],
						 [newFontName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
						 kFontPostscriptName,kFontNoPlatform,kFontNoScript,kFontNoLanguage,
						 &newFontID);
	if( newFontID == kATSUInvalidFontID ) {
		printf(ERR_PREFIX "Could not find font!\n");
		return;
	}
	
	status = ATSUSetAttributes(defaultStyle, 1, styleTags, styleSizes, styleValues);
	if(status != noErr) {
		printf(ERR_PREFIX "Could not set font!\n");
		return;
	}
	
	if( fontName )
		[fontName release];
	fontName = newFontName;
	[fontName retain];
	
	// since not all fonts have the same size we need to redo our line breaks
	[self setWidth:lineWidth];

	_widthDirty = YES;
}

- (void)setFontSize:(float)theSize
{
	OSStatus status;
	
	Fixed atsuSize = FloatToFixed(theSize);
	ATSUAttributeTag styleTags[] = {kATSUSizeTag};
	ByteCount styleSizes[] = {sizeof(Fixed)};
	ATSUAttributeValuePtr styleValues[] = {&atsuSize};
	
	status = ATSUSetAttributes(defaultStyle, 1, styleTags, styleSizes, styleValues);
	if( status != noErr )
		printf(ERR_PREFIX "could not set font size!\n");
	
	ByteCount actualSize;
	status = ATSUGetAttribute(defaultStyle,kATSUSizeTag,sizeof(Fixed),&atsuSize,&actualSize);
	fontSize = FixedToFloat(atsuSize);
	
	// we also need to redo our line breaks since the size has changed.
	_widthDirty = YES;
	[self setWidth:lineWidth];
}
- (float)fontSize
{
	return fontSize;
}

- (void)setLeading:(float)newLeading
{
	OSStatus status;
	
	ATSUTextMeasurement leadingValue = FloatToFixed(0.0f);
	ATSUAttributeTag styleTags[] = {kATSULeadingTag};
	ByteCount styleSizes[] = {sizeof(ATSUTextMeasurement)};
	ATSUAttributeValuePtr styleValues[] = {&leadingValue};
	
	status = ATSUSetAttributes(defaultStyle, 1, styleTags, styleSizes, styleValues);
	if( status != noErr ) {
		printf(ERR_PREFIX "could not set leading!\n");
		return;
	}
	
	leading = FloatToFixed(newLeading);
	
	[self recalculateLineHeights];
}

- (void)setAlignment:(TIPTextAlignment)newAlignment
{
	OSStatus status;
	
	// Layout attribs (flush factor)
	ATSUAttributeTag layoutTags[] = {kATSULineFlushFactorTag};
	ByteCount layoutSizes[] = {sizeof(Fract)};
	Fract myFlushFactor;
	ATSUAttributeValuePtr layoutValues[] = {&myFlushFactor};
	
	switch(newAlignment) {
		case kTIPTextAlignmentLeft:
			myFlushFactor = kATSUStartAlignment;
			break;
		case kTIPTextAlignmentRight:
			myFlushFactor = kATSUEndAlignment;
			break;
		case kTIPTextAlignmentCenter:
			myFlushFactor = kATSUCenterAlignment;
			break;
		default:
			printf( ERR_PREFIX "not a supported alignment value!\n");
			return;
			break;
	}
	
	status = ATSUSetLayoutControls(defaultLayout, 1, layoutTags, layoutSizes, layoutValues);
	if(status != noErr)
		printf(ERR_PREFIX "Could not set alignment!\n");

	_widthDirty = YES;
}
- (void)setColor:(NSColor *)aColor
{
	OSStatus status;
	ATSUAttributeTag styleTags[] = {kATSURGBAlphaColorTag};
	ByteCount styleSizes[] = {sizeof(ATSURGBAlphaColor)};
	ATSURGBAlphaColor styleColor;
	ATSUAttributeValuePtr styleValues[] = {&styleColor};
	
	[[aColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&styleColor.red
															  green:&styleColor.green
															   blue:&styleColor.blue
															  alpha:&styleColor.alpha];
	
	status = ATSUSetAttributes(defaultStyle, 1, styleTags, styleSizes, styleValues);
	if(status != noErr)
		printf(ERR_PREFIX "Could not set new color!\n");
}

- (void)setText:(NSString *)newText
{
	OSStatus status;
	unsigned newTextLength = [newText lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] + 1;
	
	if( textBuffer != NULL )
		free(textBuffer);
	textBuffer = (UniChar *)malloc( newTextLength );
	if( textBuffer == NULL ) {
		printf(ERR_PREFIX "Could not allocate space for string!\n");
		return;
	}

	if( ![newText getCString:(char *)textBuffer maxLength:newTextLength encoding:NSUnicodeStringEncoding] ) {
		printf(ERR_PREFIX "could not copy text into buffer!\n");
		return;
	}
	textLength = [newText length];
	
	status = ATSUSetTextPointerLocation(defaultLayout,
										textBuffer,
										kATSUFromTextBeginning,
										kATSUToTextEnd,
										textLength);
	if( status != noErr )
		printf(ERR_PREFIX "Could not set new text!\n");
	
	status = ATSUSetRunStyle(defaultLayout,defaultStyle,0, textLength);
	if( status != noErr )
		printf(ERR_PREFIX "Could not assign style to new text!\n");

	_widthDirty = YES;
}

- (void)setShadowWithOffset:(NSSize)anOffset color:(NSColor *)aColor blur:(float)blur
{
	OSStatus status;
	ATSUAttributeTag styleTags[] = {kATSUStyleDropShadowTag,
		kATSUStyleDropShadowOffsetOptionTag,
		kATSUStyleDropShadowColorOptionTag,
		kATSUStyleDropShadowBlurOptionTag};
	ByteCount styleSizes[] = {sizeof(Boolean), sizeof(CGSize), sizeof(CGColorRef), sizeof(float)};
	Boolean shadowOn = YES;
	float rgba[4] = {0.0f, 0.0f, 0.0f, 0.0f};
	[[aColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&rgba[0]
																  green:&rgba[1]
																   blue:&rgba[2]
																  alpha:&rgba[3] ];
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGColorRef shadowColor = CGColorCreate(colorSpaceRef, rgba);
	ATSUAttributeValuePtr styleValues[] = {&shadowOn, (CGSize *)&anOffset, &shadowColor, &blur};
	
	status = ATSUSetAttributes(defaultStyle, 4, styleTags, styleSizes, styleValues);
	if(status != noErr)
		printf(ERR_PREFIX "Could not set shadow!\n");
	
	CGColorRelease(shadowColor);
	CGColorSpaceRelease(colorSpaceRef);
}

- (NSSize)containerSize
{
	NSSize containerSize = NSMakeSize(lineWidth,FixedToFloat(totalHeight));
	return containerSize;
}

#define MINIMUM_STEPSIZE 0.5f
- (void)fitTextInRect:(NSRect)rect
{
	if( textLength == 0 )
		return;
	
	[self setWidth:rect.size.width];
	[self setFontSize:ceilf(rect.size.height/(float)lineCount)];
	float stepSize = fontSize;
	if( stepSize <= 1 ) {
		stepSize = 2;
		[self setFontSize:(float)stepSize];
	}
	int passCount = 0;
	while( stepSize > MINIMUM_STEPSIZE || stepSize < -MINIMUM_STEPSIZE || FixedToFloat(totalHeight) > rect.size.height ) {
		if( FixedToFloat(totalHeight) < rect.size.height ) {
			[self setFontSize:fontSize+stepSize];
		} else {
			if( stepSize > MINIMUM_STEPSIZE )
				stepSize /= 2.0f;
			[self setFontSize:fontSize-stepSize];
		}
		passCount++;
	}
	
#ifdef MINIMUM_FONTSIZE
	if( fontSize < MINIMUM_FONTSIZE )
		[self setFontSize:MINIMUM_FONTSIZE];
#endif
}

/*==================*/
#pragma mark Drawing
/*==================*/

/*
 * This will draw the string in the rect given and will try
 * to center it in the rect. If it will not fit in the rect
 * then it will align the string at the top.
 */

- (void)drawTextInRect:(NSRect)rect inContext:(CGContextRef)cxt
{
	OSStatus status;
	unsigned thisLine;
	
	[self setWidth:rect.size.width];
	
	if( _fitInRect )
		[self fitTextInRect:rect];
	
	Fixed fX = FloatToFixed(rect.origin.x);
	Fixed fY = FloatToFixed(rect.origin.y + rect.size.height) - firstAscent;

	// TODO: I should have some sort of alignment property to decide
	// when to do this or not.
	if( totalHeight < FloatToFixed(rect.size.height) )
		fY -= FloatToFixed( (rect.size.height-FixedToFloat(totalHeight))/2.0f );
	
	// clip to our rect so we don't go outside the lines...
	// TODO: Stop printing if we're going to go outsidethe lines and print
	// ellipsis as last character
	CGContextSaveGState(cxt);
	CGContextClipToRect(cxt, *(CGRect *)&rect);
	
	ATSUAttributeTag tags[] = { kATSUCGContextTag };
	ByteCount valueSizes[] = { sizeof(CGContextRef) };
	ATSUAttributeValuePtr values[] = { &cxt };
	status = ATSUSetLayoutControls(defaultLayout, 1, tags, valueSizes, values);
	
	for(thisLine=0; thisLine<lineCount; thisLine++) {
		ATSUDrawText(defaultLayout, endOfLines[thisLine], endOfLines[thisLine+1]-endOfLines[thisLine], fX, fY);
		fY -= lineHeights[thisLine];
	}

	CGContextRestoreGState(cxt);
}

@end

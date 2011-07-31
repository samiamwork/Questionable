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

- (id)init
{
	if( (self = [super init]) ) {
		CGFloat black[4] = {0.0, 0.0, 0.0, 1.0};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		_color = CGColorCreate(colorSpace, black);
		CGColorSpaceRelease(colorSpace);

		NSFont* sysFont;
		_fontSize          = [NSFont systemFontSize];
		sysFont            = [NSFont systemFontOfSize:_fontSize];
		_fontName          = [[sysFont fontName] retain];
		_font              = (CTFontRef)[sysFont retain];
		_lineWidth         = CGFLOAT_MAX;

		[self setText:@"Text not set!"];
		[self setAlignment:kTIPTextAlignmentCenter];

		_truncate = NO;
	}
	
	return self;
}

- (void)dealloc
{
	if(_attributedString)
		CFRelease(_attributedString);
	[_fontName release];
	CFRelease(_font);
	
	[super dealloc];
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

- (void)applyAttributes
{
	CFRange stringRange = CFRangeMake(0, CFAttributedStringGetLength(_attributedString));

	CTLineBreakMode lineBreakMode = _truncate ? kCTLineBreakByTruncatingTail : kCTLineBreakByWordWrapping;
	CTParagraphStyleSetting paragraphSettings[] = {
		{
			kCTParagraphStyleSpecifierLineBreakMode,
			sizeof(CTLineBreakMode),
			&lineBreakMode
		},
		{
			kCTParagraphStyleSpecifierAlignment,
			sizeof(CTTextAlignment),
			&_alignment
		}
	};
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphSettings, sizeof(paragraphSettings)/sizeof(paragraphSettings[0]));
	// TODO: It's pretty ham-fisted to set them all at once but this is just to get things working
	NSDictionary* styleDict = [NSDictionary dictionaryWithObjectsAndKeys:
							   (id)_font , kCTFontAttributeName,
							   (id)_color, kCTForegroundColorAttributeName,
							   (id)paragraphStyle, kCTParagraphStyleAttributeName,
							   nil];
	CFAttributedStringSetAttributes(_attributedString, stringRange, (CFDictionaryRef)styleDict, true);

	CFRelease(paragraphStyle);
}

- (void)setFontWithName:(NSString*)fontName
{
	if(fontName == _fontName)
		return;

	[_fontName release];
	_fontName = [fontName retain];
	CFRelease(_font);
	_font = CTFontCreateWithName((CFStringRef)_fontName, _fontSize, NULL);

	[self applyAttributes];
}

- (void)setFontSize:(float)theSize
{
	CFRelease(_font);
	_fontSize = theSize;
	_font = CTFontCreateWithName((CFStringRef)_fontName, theSize, NULL);

	[self applyAttributes];
}

- (CGFloat)fontSize
{
	return _fontSize;
}

- (void)setAlignment:(TIPTextAlignment)newAlignment
{
	switch(newAlignment) {
		case kTIPTextAlignmentLeft:
			_alignment = kCTLeftTextAlignment;
			break;
		case kTIPTextAlignmentRight:
			_alignment = kCTRightTextAlignment;
			break;
		case kTIPTextAlignmentCenter:
			_alignment = kCTCenterTextAlignment;
			break;
		default:
			printf( ERR_PREFIX "not a supported alignment value!\n");
			break;
	}

	[self applyAttributes];
}

- (void)setColor:(NSColor *)aColor
{
	CGColorRelease(_color);
	CGFloat rgba[4];
	[[aColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&rgba[0]
																  green:&rgba[1]
																   blue:&rgba[2]
																  alpha:&rgba[3]];
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_color = CGColorCreate(colorSpace, rgba);
	CGColorSpaceRelease(colorSpace);

	[self applyAttributes];
}

- (void)setText:(NSString *)newText
{
	if(_attributedString)
		CFRelease(_attributedString);
	if(newText != nil)
	{
		_attributedString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		CFAttributedStringReplaceString(_attributedString, CFRangeMake(0, 0), (CFStringRef)newText);
	}
	else
	{
		_attributedString = NULL;
	}

	[self applyAttributes];
}

- (void)setTruncates:(BOOL)shouldTruncate
{
	if( shouldTruncate == _truncate )
		return;
	
	_truncate = shouldTruncate;

	[self applyAttributes];
}

- (NSUInteger)lineCount
{
	CFRange fitInRange;
	CGSize size                  = CGSizeMake(_lineWidth, CGFLOAT_MAX);
	CFRange stringRange          = CFRangeMake(0, CFAttributedStringGetLength(_attributedString));
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(_attributedString);
	CGSize textSize              = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, stringRange, NULL, size, &fitInRange);
	CGRect textRect              = CGRectMake(0.0, 0.0, textSize.width, textSize.height);

	CGMutablePathRef rectPath = CGPathCreateMutable();
	CGPathAddRect(rectPath, NULL, textRect);
	CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, stringRange, rectPath, NULL);
	CFArrayRef lines     = CTFrameGetLines(textFrame);
	NSUInteger lineCount = CFArrayGetCount(lines);

	CFRelease(rectPath);
	CFRelease(textFrame);
	CFRelease(framesetter);

	return lineCount;
}

- (void)setLineWidth:(CGFloat)lineWidth
{
	_lineWidth = lineWidth;
}

- (NSSize)containerSize
{
	CFRange fitInRange;
	CGSize size                  = CGSizeMake(_lineWidth, CGFLOAT_MAX);
	CFRange stringRange          = CFRangeMake(0, CFAttributedStringGetLength(_attributedString));
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(_attributedString);
	CGSize textSize              = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, stringRange, NULL, size, &fitInRange);

	CFRelease(framesetter);
	return NSMakeSize(textSize.width, textSize.height);
}

- (void)fitTextInRect:(NSRect)rect
{
	_lineWidth = rect.size.width;
	CGRect r                  = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	CFRange stringRange       = CFRangeMake(0, CFAttributedStringGetLength(_attributedString));
	CTFramesetterRef framesetter;
	CFRange rangeThatFits;

	framesetter = CTFramesetterCreateWithAttributedString(_attributedString);
	CTFramesetterSuggestFrameSizeWithConstraints(framesetter, stringRange, NULL, r.size, &rangeThatFits);
	CFRelease(framesetter);
	if(rangeThatFits.length < stringRange.length)
	{
		// Binary search using the new value as a lower-bound
		CGFloat lowerBound = floor(_fontSize*((CGFloat)rangeThatFits.length/(CGFloat)stringRange.length));
		CGFloat upperBound = floor(_fontSize);
		while(upperBound - lowerBound > 1.0)
		{
			CGFloat midpoint = floor((upperBound-lowerBound)/2.0)+lowerBound;
			[self setFontSize:midpoint];
			// TODO: I'm not sure I need to recreate the framesetter every time
			framesetter = CTFramesetterCreateWithAttributedString(_attributedString);
			r.size.height = CGFLOAT_MAX;
			CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, stringRange, NULL, r.size, &rangeThatFits);
			CFRelease(framesetter);
			if(textSize.height > rect.size.height)
			{
				// Too big
				upperBound = midpoint;
			}
			else
			{
				// too small
				lowerBound = midpoint;
			}
		}
		[self setFontSize:lowerBound];
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

- (void)drawTextInRect:(NSRect)rect inContext:(CGContextRef)ctx
{
	[self setLineWidth:rect.size.width];

	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(_attributedString);
	CGMutablePathRef rectPath    = CGPathCreateMutable();
	CFRange          textRange   = CFRangeMake(0, CFAttributedStringGetLength(_attributedString));
	CFRange          fitInRange;
	CGSize           textSize    = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, textRange, NULL, CGSizeMake(_lineWidth, CGFLOAT_MAX), &fitInRange);

	if(textSize.height < rect.size.height)
		rect.origin.y -= (rect.size.height-textSize.height)/2.0;
	else if(textSize.height > rect.size.height)
	{
		rect.size.height = textSize.height;
		rect.origin.y += (textSize.height-rect.size.height)/2.0;
	}
	CGPathAddRect(rectPath, NULL, CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height));

	CGContextSaveGState(ctx);
	{
		CTFrameRef theTextFrame = CTFramesetterCreateFrame(framesetter, textRange, rectPath, NULL);
		CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
		CTFrameDraw(theTextFrame, ctx);
		CFRelease(theTextFrame);
	}
	CGContextRestoreGState(ctx);
	CFRelease(rectPath);
	CFRelease(framesetter);
}

@end

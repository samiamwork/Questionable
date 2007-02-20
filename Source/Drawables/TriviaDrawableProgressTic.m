//
//  TriviaDrawableProgressTic.m
//  TriviaPlayer
//
//  Created by Nur Monson on 11/21/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaDrawableProgressTic.h"


@implementation TriviaDrawableProgressTic

- (id)init
{
	if( (self = [super init]) ) {
		boxGradient = TIPMutableGradientCreate();
		TIPGradientAddRGBColorStop(boxGradient,0.0f,0.95f,0.95f,0.95f, 0.5f);
		TIPGradientAddRGBColorStop(boxGradient,11.5f/23.0f, 0.83f,0.83f,0.83f,0.5f);
		TIPGradientAddRGBColorStop(boxGradient,11.5f/23.0f, 0.95f,0.95f,0.95f,0.5f);
		TIPGradientAddRGBColorStop(boxGradient,1.0f,0.92f,0.92f,0.92f,0.5f);
		
		bgColor = nil;
	}

	return self;
}

- (void)dealloc
{
	TIPGradientRelease( boxGradient );
	if( bgColor )
		[bgColor release];

	[super dealloc];
}

- (NSColor *)backgroundColor
{
	return bgColor;
}
- (void)setBackgroundColor:(NSColor *)aColor
{
	if( aColor == bgColor )
		return;
	
	if( bgColor )
		[bgColor release];
	bgColor = [aColor retain];
}

- (void)drawInRect:(NSRect)theRect inContext:(CGContextRef)theContext
{
	NSRect innerRect = NSInsetRect(theRect,2.5f,2.5f);
	
	CGContextSaveGState(theContext); {
		float r,g,b,a;
		if( bgColor ) {
			[bgColor getRed:&r green:&g blue:&b alpha:&a];
			CGContextSetRGBFillColor( theContext, r,g,b,a );
			CGContextFillRect( theContext, *(CGRect *)&innerRect );
		}
		TIPGradientAxialFillRect( theContext, boxGradient, *(CGRect *)&innerRect, 90.0f);
		
		CGContextSetLineWidth( theContext, 1.0f );
		CGContextSetRGBStrokeColor( theContext, 0.7f,0.7f,0.7f,1.0f);
		
		CGContextStrokeRect( theContext, *(CGRect *)&innerRect );
	} CGContextRestoreGState(theContext);
}
@end

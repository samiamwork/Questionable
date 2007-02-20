//
//  TriviaDrawablePlayerBadge.m
//  TriviaPlayer
//
//  Created by Nur Monson on 10/26/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaDrawableBadge.h"
#include "TIPCGUtils.h"

@implementation TriviaDrawableBadge

- (id)init
{
	if( (self = [super init]) ) {
		theText = nil;
		/*
		bgGradient = [CTGradient gradientWithBeginningColor:[NSColor colorWithCalibratedRed:1.0f green:0.4f blue:0.4f alpha:1.0f]
												endingColor:[NSColor colorWithCalibratedRed:0.7f green:0.3f blue:0.3f alpha:1.0f]];
		[bgGradient retain];
		 */
		bgGradient = TIPMutableGradientCreate();
		TIPGradientAddRGBColorStop(bgGradient,0.0f,1.0f,0.4f,0.4f,1.0f);
		TIPGradientAddRGBColorStop(bgGradient,1.0f,0.7f,0.3f,0.3f,1.0f);
		outline = NULL;
		
		textContainer = [[TIPTextContainer containerWithString:@"..."
														 color:[NSColor colorWithCalibratedWhite:1.0f alpha:1.0f]
													  fontName:@"HelveticaNeue"] retain];
		
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	if( theText )
		[theText release];
	
	if( outline )
		CGPathRelease( outline );
	[textContainer release];
	TIPGradientRelease( bgGradient );
}

- (void)setText:(NSString *)newText
{
	if( newText == theText )
		return;
	
	if( theText != nil )
		[theText release];
	
	if( newText != nil )
		[newText retain];
	
	theText = newText;
	[textContainer setText:theText];
}

- (void)drawInRect:(NSRect)theRect inContext:(CGContextRef)theContext
{
	CGContextSaveGState( theContext );
	
	if( outline )
		CGPathRelease( outline );
	
	float radius = theRect.size.height * 0.2f;
	outline = TIPCGUtilsPartialRoundedBoxCreate(*(CGRect *)&theRect,radius,TRUE,FALSE,TRUE,FALSE);
	
	//[bgGradient fillPath:outline inContext:theContext withAngle:90.0f];
	TIPGradientAxialFillPath(theContext,bgGradient,outline,90.0f);
	
	CGContextSetRGBStrokeColor( theContext, 0.5f,0.5f,0.5f,0.5f);
	CGContextAddPath( theContext, outline );
	CGContextStrokePath( theContext );
	
	NSRect textBox = theRect;
	textBox.size.width -= 2.0f*radius;
	textBox.origin.x += radius;
	
	[textContainer setFontSize:textBox.size.height/2.0f];
	[textContainer drawTextInRect:textBox inContext:theContext];
	
	CGContextRestoreGState( theContext );
}
@end

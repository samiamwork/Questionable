//
//  TriviaDrawableCategory.m
//  TriviaPlayer
//
//  Created by Nur Monson on 10/8/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaDrawableCategoryTitleBox.h"
#include "TIPCGUtils.h"

#define LINEWIDTH 0.5f

@implementation TriviaDrawableCategoryTitleBox

- (id)init
{
	if( (self = [super init]) ) {
		
		box = NULL;
		/*
		bgGradient = [CTGradient gradientWithBeginningColor:[NSColor colorWithCalibratedRed:0.2f green:0.2f blue:0.7f alpha:1.0f]
												endingColor:[NSColor colorWithCalibratedRed:0.4f green:0.4f blue:0.9f alpha:1.0f] ];
		//bgGradient = [CTGradient aquaNormalGradient];
		[bgGradient retain];
		 */
		bgGradient = TIPMutableGradientCreate();
		TIPGradientAddRGBColorStop(bgGradient,0.0f, 0.2f,0.2f,0.7f,1.0f);
		TIPGradientAddRGBColorStop(bgGradient,1.0f,0.4f,0.4f,0.9f,1.0f);
		
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	if( box )
		CGPathRelease(box);
	
	TIPGradientRelease(bgGradient);
}

- (void)drawInRect:(NSRect)theRect inContext:(CGContextRef)theContext
{
	CGContextSaveGState( theContext );
	
	if( box )
		CGPathRelease(box);
	
	float margin = theRect.size.width*0.1f;
	theRect.origin.x += margin;
	theRect.size.width -= margin * 2.0f;
	
	box = TIPCGUtilsPartialRoundedBoxCreate(*(CGRect *)&theRect, 10.0f, FALSE, TRUE, TRUE, FALSE);
	//[bgGradient fillPath:box inContext:theContext withAngle:90.0f];
	TIPGradientAxialFillPath(theContext,bgGradient,box,90.0f);
	//CGContextSetRGBFillColor(theContext,0.5f,0.5f,0.9f,1.0f);
	//CGContextAddPath(theContext,box);
	//CGContextFillPath(theContext);
	
	CGContextSetRGBStrokeColor(theContext, 0.4f, 0.4f, 0.4f, 5.0f);
	CGContextAddPath(theContext, box);
	CGContextSetLineWidth(theContext, LINEWIDTH);
	CGContextStrokePath(theContext);
	
	CGContextRestoreGState( theContext );
}

@end

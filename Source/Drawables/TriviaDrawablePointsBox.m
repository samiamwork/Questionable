//
//  TriviaDrawablePoints.m
//  TriviaPlayer
//
//  Created by Nur Monson on 10/8/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaDrawablePointsBox.h"
#include "TIPCGUtils.h"

#define LINEWIDTH 2.0f

@implementation TriviaDrawablePointsBox

- (id)init
{
	if( (self = [super init]) ) {
		
		bgGradient = TIPMutableGradientCreate();
		TIPGradientAddRGBColorStop(bgGradient,0.0f,0.2f,0.2f,0.7f,1.0f);
		TIPGradientAddRGBColorStop(bgGradient,1.0f,0.4f,0.4f,0.9f,1.0f);
		
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	TIPGradientRelease(bgGradient);
}

- (void)drawInRect:(NSRect)theRect inContext:(CGContextRef)theContext
{
	CGContextSaveGState( theContext );
	
	float margin = theRect.size.width*0.1f;
	theRect.origin.x += margin;
	theRect.size.width -= margin*2.0f;
	
	//[bgGradient fillRect:theRect angle:0.0f withContext:theContext];
	TIPGradientAxialFillRect(theContext,bgGradient,*(CGRect *)&theRect,0.0f);
	
	CGContextSetRGBStrokeColor(theContext, 0.9f, 0.9f, 0.9f, 0.9f);
	//CGContextAddPath(theContext, box);
	CGContextSetLineWidth(theContext, 0.5f);
	CGContextStrokeRect(theContext,*(CGRect *)&theRect);
	//CGContextStrokePath(theContext);
	
	CGContextRestoreGState( theContext );
}


@end

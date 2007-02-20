//
//  TriviaDrawablePlayerStatusBox.m
//  TriviaPlayer
//
//  Created by Nur Monson on 10/25/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaDrawablePlayerStatusBox.h"
#include "TIPCGUtils.h"


@implementation TriviaDrawablePlayerStatusBox

- (id)init
{
	if( (self = [super init]) ) {
		boxGradient = TIPMutableGradientCreate();
		TIPGradientAddRGBColorStop(boxGradient,0.0f,0.5f,0.5f,0.9f,1.0f);
		TIPGradientAddRGBColorStop(boxGradient,1.0f,0.2f,0.2f,0.7f,1.0f);
		
		hilightGradient = TIPMutableGradientCreate();
		TIPGradientAddRGBColorStop(hilightGradient,0.0f,1.0f,1.0f,1.0f,0.0f);
		TIPGradientAddRGBColorStop(hilightGradient,1.0f,1.0f,1.0f,1.0f,1.0f);
		
		pillBox = NULL;
		shineBox = NULL;
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	if(pillBox)
		CGPathRelease(pillBox);
	if( shineBox )
		CGPathRelease( shineBox );
	
	TIPGradientRelease( boxGradient );
	TIPGradientRelease( hilightGradient );
}

- (void)drawInRect:(NSRect)theRect inContext:(CGContextRef)theContext
{
	CGContextSaveGState( theContext );
	
	if( pillBox )
		CGPathRelease( pillBox );
	if( shineBox )
		CGPathRelease( shineBox );
	
	float margin = 1.0f; //theRect.size.height * 0.05f;
	pillBox = TIPCGUtilsPill( CGRectMake(margin,margin,theRect.size.width-2.0f*margin,theRect.size.height-2.0f*margin));
	
	//[boxGradient fillPath:pillBox inContext:theContext withAngle:90.0f];
	TIPGradientAxialFillPath(theContext,boxGradient,pillBox,90.0f);
	CGContextSetRGBStrokeColor( theContext, 0.5f,0.5f,0.5f,0.5f );
	CGContextSetLineWidth( theContext, 1.0f);
	CGContextAddPath( theContext,pillBox );
	CGContextStrokePath( theContext );

	margin = theRect.size.height*0.06f;
	float shineHeight = 4.0f*margin;
	float bigRadius = theRect.size.height/2.0f;
	shineBox = TIPCGUtilsPill( CGRectMake(bigRadius-shineHeight/2.0f,
										  theRect.size.height-shineHeight - margin,
										  // margin is for tweak factor
										  theRect.size.width-bigRadius*2.0f+shineHeight + margin,
										  shineHeight) );
	//[hilightGradient fillPath:shineBox inContext:theContext withAngle:90.0f];
	TIPGradientAxialFillPath(theContext,hilightGradient,shineBox,90.0f);
	
	CGContextRestoreGState( theContext );
}
@end

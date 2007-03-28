//
//  TriviaStatusView.m
//  Questionable
//
//  Created by Nur Monson on 3/27/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TriviaStatusView.h"


@implementation TriviaStatusView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	NSRect bounds = [self bounds];
	
	CGContextSetRGBFillColor(cxt,0.8f,0.8f,0.8f,1.0f);
	CGContextFillRect(cxt, *(CGRect *)&bounds);
	
	CGContextSetLineWidth(cxt,2.0f);
	CGContextSetRGBStrokeColor(cxt,0.2f,0.2f,0.2f,0.5f);
	CGContextMoveToPoint(cxt,bounds.origin.x,bounds.origin.y+bounds.size.height);
	CGContextAddLineToPoint(cxt,bounds.origin.x+bounds.size.width,bounds.origin.y+bounds.size.height);
	CGContextStrokePath(cxt);
	/*
	TIPMutableGradientRef bgGradient = TIPMutableGradientCreate();
	TIPGradientAddRGBColorStop(bgGradient,0.0f,0.3f,0.3f,0.3f,1.0f);
	TIPGradientAddRGBColorStop(bgGradient,0.1f,0.6f,0.6f,0.6f,1.0f);
	
	TIPGradientAxialFillRect(cxt,bgGradient,CGRectMake(bounds.origin.x,bounds.origin.y+20.0f,bounds.size.width,bounds.size.height-20.0f),90.0f);
	TIPGradientRelease(bgGradient);
	 */
}

@end

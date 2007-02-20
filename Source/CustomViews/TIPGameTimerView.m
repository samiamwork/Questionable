//
//  TIPGameTimerView.m
//  TriviaPlayer
//
//  Created by Nur Monson on 11/20/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TIPGameTimerView.h"


@implementation TIPGameTimerView

- (id)initWithFrame:(NSRect)frameRect
{
	if( (self = [super initWithFrame:frameRect]) ) {
		currentTime = 0.0;
		maxTime = 0.0;
		stopped = YES;
		display = TriviaTimeDisplayMiliseconds | TriviaTimeDisplaySeconds | TriviaTimeDisplayMinutes | TriviaTimeDisplayHours;
		
		timeContainer = [[TIPTextContainer containerWithString:@"1:00:00.0"] retain];
		[timeContainer setAlignment:kTIPTextAlignmentCenter];
		stoppedContainer = [[TIPTextContainer containerWithString:@"0:00:00.0"] retain];
		[stoppedContainer setAlignment:kTIPTextAlignmentCenter];
		[stoppedContainer setColor:[NSColor colorWithCalibratedWhite:0.5f alpha:1.0f]];
		
		outline = NULL;
		bgGradient = TIPMutableGradientCreate();
		TIPGradientAddRGBColorStop(bgGradient,0.0f,0.9137f,0.9922f,0.7059f,1.0f);
		TIPGradientAddRGBColorStop(bgGradient,1.0f,0.8510f,0.9137f,0.6863f,1.0f);
		
		ticDrawableStopped = [[TriviaDrawableProgressTic alloc] init];
		ticDrawableUnused = [[TriviaDrawableProgressTic alloc] init];
		[ticDrawableUnused setBackgroundColor:[NSColor colorWithCalibratedRed:0.4f green:1.0f blue:0.4f alpha:0.5f]];
		ticDrawableUsed = [[TriviaDrawableProgressTic alloc] init];
		[ticDrawableUsed setBackgroundColor:[NSColor colorWithCalibratedRed:0.4f green:0.4f blue:0.4f alpha:0.4f]];
	}

	return self;
}

- (void)dealloc
{	
	TIPGradientRelease(bgGradient);
	if( outline )
		CGPathRelease( outline );
	
	[timeContainer release];
	[stoppedContainer release];
	[ticDrawableStopped release];
	[ticDrawableUsed release];
	[ticDrawableUnused release];
	
	[super dealloc];
}

#pragma mark Util

NSString *stringForTime(NSTimeInterval aTime)
{
	int h = (int)(aTime/(60.0*60.0));
	aTime -= h*60.0*60.0;
	int m = (int)(aTime/60.0);
	aTime -= m*60.0;
	int s = (int)(aTime);
	aTime -= s;
	aTime *= 10.0;
	int ms = (int)aTime;

	NSString *displayString;
	displayString = [NSString stringWithFormat:@"%d:%02d:%02d.%01d", h, m, s, ms];
	
	return displayString;
}

#pragma mark Set and Get

- (NSTimeInterval)currentTime
{
	return currentTime;
}
- (void)setCurrentTime:(NSTimeInterval)newTime
{
	if( newTime > maxTime )
		newTime = maxTime;
	
	if( newTime == currentTime )
		return;
	
	currentTime = newTime;
	[timeContainer setText:stringForTime(currentTime)];
	if( !stopped )
		[self setNeedsDisplay:YES];
}

- (NSTimeInterval)maxTime
{
	return maxTime;
}
- (void)setMaxTime:(NSTimeInterval)newMaxTime
{
	if( newMaxTime == maxTime )
		return;

	maxTime = newMaxTime;
	if( maxTime > currentTime )
		currentTime = maxTime;
	
	if( !stopped )
		[self setNeedsDisplay:YES];
}

- (BOOL)stopped
{
	return stopped;
}
- (void)setStopped:(BOOL)isStopped
{
	if( isStopped == stopped )
		return;

	stopped = isStopped;
	[self setNeedsDisplay:YES];
}

- (TriviaTimeDisplay)display
{
	return display;
}
- (void)setDisplay:(TriviaTimeDisplay)newDisplay
{
	display = newDisplay;
}

#pragma mark drawing

- (void)drawRect:(NSRect)theRect
{
	if( outline )
		CGPathRelease( outline );
	outline = TIPCGUtilsRoundedBoxCreate(*(CGRect *)&theRect,0.0f,5.0f,1.0);
	
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState( cxt );
	
	//draw background
	TIPGradientAxialFillPath( cxt, bgGradient, outline, 90.0f );
	CGContextSetLineWidth( cxt , 1.0f );
	CGContextSetRGBStrokeColor( cxt, 0.0f,0.0f,0.0f,0.3f );
	CGContextAddPath( cxt, outline );
	CGContextStrokePath( cxt );
	
	NSRect indicatorRect;
	NSRect textRect;
	NSDivideRect( theRect, &textRect, &indicatorRect, 20.0f,NSMinYEdge );
	
	// draw indicator
	NSRect innerRect = NSInsetRect(indicatorRect,5.0f,5.0f);
	float ticWidth = innerRect.size.width/10.0f;
	CGPoint aPoint = *(CGPoint *)&innerRect.origin;
	int ticIndex;
	CGLayerRef ticLayerRef;
	if( stopped ) {
		ticLayerRef = [ticDrawableStopped makeLayerForSize:NSMakeSize(ticWidth,innerRect.size.height) withContext:cxt];
		for( ticIndex = 0; ticIndex < 10; ticIndex++) {
			CGContextDrawLayerAtPoint( cxt, aPoint, ticLayerRef );
			aPoint.x += ticWidth;
		}
	} else {
		float precentDone = (float)(currentTime/maxTime);
		
		CGLayerRef ticUsedLayerRef = [ticDrawableUsed makeLayerForSize:NSMakeSize(ticWidth,innerRect.size.height) withContext:cxt];
		CGLayerRef ticUnusedLayerRef = [ticDrawableUnused makeLayerForSize:NSMakeSize(ticWidth,innerRect.size.height) withContext:cxt];
		while( (aPoint.x - innerRect.origin.x)/innerRect.size.width < precentDone ) {
			CGContextDrawLayerAtPoint( cxt, aPoint, ticUnusedLayerRef );
			aPoint.x += ticWidth;
		}
		while( aPoint.x < innerRect.origin.x+innerRect.size.width ) {
			CGContextDrawLayerAtPoint( cxt, aPoint, ticUsedLayerRef );
			aPoint.x += ticWidth;
		}
	}
		
	
	// draw text
	TIPTextContainer *theText = timeContainer;
	if( stopped )
		theText = stoppedContainer;
	[theText setFontSize:15.0f];
	[theText drawTextInRect:textRect inContext:cxt];
	
	CGContextRestoreGState( cxt );
}
@end

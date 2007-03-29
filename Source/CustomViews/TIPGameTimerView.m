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
		
		timeContainer = [[TIPTextContainer containerWithString:@"00"] retain];
		[timeContainer setAlignment:kTIPTextAlignmentCenter];
		[timeContainer setColor:[NSColor colorWithCalibratedWhite:0.9f alpha:1.0f]];
		stoppedContainer = [[TIPTextContainer containerWithString:@"00"] retain];
		[stoppedContainer setAlignment:kTIPTextAlignmentCenter];
		[stoppedContainer setColor:[NSColor colorWithCalibratedWhite:0.9f alpha:1.0f]];

		_countdown = YES;
	}

	return self;
}

- (void)dealloc
{	
	[timeContainer release];
	[stoppedContainer release];
	
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
	/*
	aTime -= s;
	aTime *= 10.0;
	int ms = (int)aTime;
	 */
	NSString *displayString;
	m += h*60;
	if( m == 0 )
		displayString = [NSString stringWithFormat:@":%02d", s];
	else
		displayString = [NSString stringWithFormat:@"%02d", m];
	
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
	
	NSTimeInterval oldTime = currentTime;
	currentTime = newTime;
	NSTimeInterval timeToReport = _countdown ? maxTime-currentTime : currentTime;
	[timeContainer setText:stringForTime(timeToReport)];
	
	if( stopped || (floor(currentTime/60.0)-floor(oldTime/60.0) < 1.0 && maxTime-currentTime > 1.0) )
		return;
	
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

- (NSRect)fitRect:(NSRect)inputRect inRect:(NSRect)inRect
{
	NSRect outputRect;
	outputRect.origin = inRect.origin;
	float rectAspectRatio = inRect.size.width/inRect.size.height;
	float imageAspectRatio = inputRect.size.width/inputRect.size.height;
	
	float zoom;
	if( imageAspectRatio < rectAspectRatio ) {
		zoom = inRect.size.height/inputRect.size.height;
		outputRect.size.height = inRect.size.height;
		outputRect.size.width = roundf( inputRect.size.width*zoom);
		outputRect.origin.x += roundf( (inRect.size.width - outputRect.size.width)/2.0f );
	} else {
		zoom = inRect.size.width/inputRect.size.width;
		outputRect.size.height = roundf( inputRect.size.height*zoom);
		outputRect.size.width = inRect.size.width;
		outputRect.origin.y += roundf( (inRect.size.height - outputRect.size.height)/2.0f );
	}
	
	return outputRect;
}

- (BOOL)isOpaque
{
	return NO;
}

- (void)drawRect:(NSRect)theRect
{	
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState( cxt );
	
	NSRect bounds = [self bounds];
	
	NSRect clockRect = [self fitRect:NSMakeRect(bounds.origin.x,bounds.origin.y,bounds.size.height,bounds.size.height)
							  inRect:bounds];
	clockRect = NSInsetRect(clockRect,4.0f,4.0f);
	CGMutablePathRef circle = CGPathCreateMutable();
	// draw outline
	CGContextSetLineWidth( cxt , 3.0f );
	CGPathAddArc(circle,NULL,clockRect.origin.x+clockRect.size.width/2.0f,clockRect.origin.y+clockRect.size.height/2.0f,clockRect.size.height/2.0f,0.0f,2.0f*M_PI,0);
	CGContextAddPath(cxt,circle);
	CGContextStrokePath(cxt);
	// draw background
	CGContextSetRGBFillColor(cxt,0.95f,0.95f,0.95f,1.0f);
	CGContextAddPath(cxt,circle);
	CGContextFillPath(cxt);
	CGPathRelease(circle);
	// draw indicator circle
	CGContextSetRGBStrokeColor(cxt,0.35f,0.35f,0.37f,1.0f);
	NSRect indicatorRect = NSInsetRect(clockRect,clockRect.size.height*0.1f,clockRect.size.height*0.1f);
	CGContextSetLineWidth(cxt,clockRect.size.height*0.2f);
	float percentDone = (float)((maxTime-currentTime)/maxTime);
	if( stopped )
		percentDone = 1.0f;
	CGContextAddArc(cxt,indicatorRect.origin.x+indicatorRect.size.width/2.0f,indicatorRect.origin.y+indicatorRect.size.height/2.0f,indicatorRect.size.height/2.0f,M_PI_2,M_PI_2-2.0f*M_PI*percentDone,1);
	CGContextStrokePath(cxt);
	
	// draw time background
	NSRect textRect = NSInsetRect(clockRect,clockRect.size.width*0.15f,clockRect.size.height*0.3f);
	CGContextSetRGBFillColor(cxt,0.1f,0.1f,0.1f,0.8f);
	CGMutablePathRef timePill = TIPCGUtilsPill(*(CGRect *)&textRect);
	CGContextAddPath(cxt,timePill);
	CGContextFillPath(cxt);
	CGPathRelease(timePill);
	
	// draw time
	TIPTextContainer *theText = timeContainer;
	if( stopped )
		theText = stoppedContainer;
	[theText fitTextInRect:textRect];
	[theText drawTextInRect:textRect inContext:cxt];
	
	// draw shine
	TIPMutableGradientRef whiteShine = TIPMutableGradientCreate();
	TIPGradientAddRGBColorStop(whiteShine,0.0f,1.0f,1.0f,1.0f,0.0f);
	TIPGradientAddRGBColorStop(whiteShine,1.0f,1.0f,1.0f,1.0f,0.8f);
	
	NSRect shineRect = NSInsetRect(clockRect,1.0f,1.0f);
	CGMutablePathRef shineSemicircle = CGPathCreateMutable();
	
	CGPathAddArc(shineSemicircle,NULL,shineRect.origin.x+shineRect.size.width/2.0f,shineRect.origin.y+shineRect.size.height/2.0f,shineRect.size.height/2.0f,0.0f,M_PI,0);
	CGPathCloseSubpath(shineSemicircle);
	TIPGradientAxialFillPath(cxt,whiteShine,shineSemicircle,90.0f);
	CGPathRelease(shineSemicircle);
	TIPGradientRelease(whiteShine);
	
	CGContextRestoreGState( cxt );
}
@end

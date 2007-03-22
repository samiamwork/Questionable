//
//  TriviaTimer.m
//  TriviaPlayer
//
//  Created by Nur Monson on 11/2/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaTimer.h"


@interface TriviaTimer (Private)
- (void)timerFired:(NSTimer *)theTimer;
- (void)addElapsedTime;
@end

@implementation TriviaTimer

- (id)init
{
	if( (self = [super init]) ) {
		targetObject = nil;
		lastTime = 0.0;
		timeElapsed = 0.0;
		timeLength = 0.0;
		
		stopped = YES;
		paused = NO;
		
		timer = nil;
	}
	
	return self;
}

+ (TriviaTimer *)timerWithLength:(NSTimeInterval)length interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector
{
	id newInstance = [[[self class] alloc] init];
	
	[newInstance setTimeLength:length];
	[newInstance setTimeInterval:interval];
	[newInstance setTarget:target selector:selector];
	
	return [newInstance autorelease];
}

#pragma mark Set and Get

- (NSTimeInterval)timeLength
{
	return timeLength;
}
- (void)setTimeLength:(NSTimeInterval)length
{
	if( length <= 0.0 )
		return;
	
	timeLength = length;
}
- (NSTimeInterval)timeElapsed
{
	return timeElapsed;
}
- (unsigned int)currentLevel
{
	float percentLeft = (timeLength-timeElapsed)/timeLength;
	if( percentLeft < 0.0f )
		percentLeft = 0.0f;
	
	return (unsigned int)(ceilf(4.0f*percentLeft));
}
- (void)setTimeInterval:(NSTimeInterval)interval
{
	if( interval <= 0.0 )
		return;
	
	timeInterval = interval;
}
- (void)setTarget:(id)target selector:(SEL)selector
{
	targetObject = target;
	targetSelector = selector;
}

#pragma mark running methods

// will start from the begining
- (void)start
{	
	if( timeLength <= 0.0 || timeInterval <= 0.0 )
		return;

	[self stop];
	paused = NO;
	stopped = NO;
	
	timeElapsed = 0.0;
	lastTime = [NSDate timeIntervalSinceReferenceDate];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
}

- (void)stop
{
	if( stopped )
		return;
	
	if( !paused )
		[self addElapsedTime];
	
	[timer invalidate];
	stopped = YES;
}
- (void)pause
{
	if( stopped )
		return;
	
	if( paused ) {
		// unpause
		lastTime = [NSDate timeIntervalSinceReferenceDate];
		timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
		paused = NO;
	} else {
		// pause
		[self addElapsedTime];
		[timer invalidate];
		paused = YES;
	}
}

- (BOOL)paused
{
	return paused;
}
- (BOOL)stopped
{
	return stopped;
}

- (void)timerFired:(NSTimer *)theTimer
{
	[self addElapsedTime];
	
	if( timeElapsed > timeLength ) {
		[timer invalidate];
		timer = nil;
		
		timeElapsed = 0.0;
		stopped = YES;
	}
	
	if( targetObject == nil )
		return;
	
	[targetObject performSelector:targetSelector];
}

- (void)addElapsedTime
{
	NSTimeInterval thisTime = [NSDate timeIntervalSinceReferenceDate];
	NSTimeInterval dt = thisTime - lastTime;
	timeElapsed += dt;
	lastTime = thisTime;
}
@end

//
//  SimpleTimerView.m
//  Questionable
//
//  Created by Nur Monson on 6/26/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "SimpleTimerView.h"


@implementation SimpleTimerView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_value = 0.0f;
		_timerAnimation = [[TransitionAnimation alloc] initWithDuration:1.0 animationCurve:NSAnimationLinear];
		[_timerAnimation setAnimationBlockingMode:NSAnimationNonblocking];
		[_timerAnimation setDelegate:self];
    }
    return self;
}

- (BOOL)isOpaque
{
	return NO;
}

- (void)drawRect:(NSRect)rect {
	NSRect bounds = [self bounds];

	if( ![_timerAnimation isAnimating] )
		return;
	
	bounds.size.height *= 1.0f-_value;
	[[NSColor colorWithCalibratedWhite:0.4f alpha:0.5f] set];
	NSRectFillUsingOperation(bounds,NSCompositeSourceOver);
}

- (void)setValue:(float)newValue
{
	if( newValue > 1.0f )
		newValue == 1.0f;
	if( newValue < 0.0f )
		newValue == 0.0f;
	
	if( newValue == _value )
		return;
	
	_value = newValue;
	[self setNeedsDisplay:YES];
}
- (float)value
{
	return _value;
}

- (void)animationTick:(TransitionAnimation *)theAnimation
{
	[self setValue:[theAnimation currentValue]];
}

- (void)startTimerOfLength:(NSTimeInterval)theLength
{
	[_timerAnimation setCurrentProgress:0.0];
	[_timerAnimation setDuration:theLength];
	[_timerAnimation startAnimation];
}
- (void)pauseTimer
{
	[_timerAnimation stopAnimation];
}
- (void)resumeTimer
{
	[_timerAnimation startAnimation];
}
- (void)stopTimer
{
	[_timerAnimation stopAnimation];
	[_timerAnimation setCurrentProgress:0.0];
}
- (void)resetTimer
{
	[_timerAnimation setCurrentProgress:0.0];
}
@end

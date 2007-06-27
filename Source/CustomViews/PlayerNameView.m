//
//  PlayerNameView.m
//  Questionable
//
//  Created by Nur Monson on 6/26/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "PlayerNameView.h"


@implementation PlayerNameView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		
    }
    return self;
}

- (void)dealloc
{
	[_fadeAnimation release];

	[super dealloc];
}

- (void)animationTick:(TransitionAnimation *)theAnimation
{
	
	float theValue = [theAnimation currentValue];
	[self setTextColor:[NSColor colorWithCalibratedHue:0.0f saturation:theValue brightness:0.4f+(0.6f*theValue) alpha:1.0f]];

}

- (void)setStringValue:(NSString *)newString
{
	[super setStringValue:newString];
	
	if( [self stringValue] == nil || [[self stringValue] isEqualToString:@""] )
		return;
	
	[self  setTextColor:[NSColor redColor]];
	
	if( _fadeAnimation == nil ) {
		_fadeAnimation = [[TransitionAnimation alloc] initWithDuration:1.0 animationCurve:NSAnimationEaseOut];
		[_fadeAnimation setDelegate:self];
		[_fadeAnimation setAnimationBlockingMode:NSAnimationNonblocking];
	}
	
	if( [_fadeAnimation isAnimating] )
		[_fadeAnimation stopAnimation];
	
	[_fadeAnimation startAnimation];
}


@end

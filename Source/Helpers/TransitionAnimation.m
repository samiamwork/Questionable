//
//  TransitionAnimation.m
//  Questionable
//
//  Created by Nur Monson on 6/26/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TransitionAnimation.h"

@interface NSObject (Private)
- (void)animationTick:(TransitionAnimation *)theAnimation;
@end

@implementation TransitionAnimation

- (void)setCurrentProgress:(NSAnimationProgress)progress {
    [super setCurrentProgress:progress];
	
	if( [self delegate] != nil && [[self delegate] respondsToSelector:@selector(animationTick:)] )
		[[self delegate] animationTick:self];
	
	if( progress == 1.0 )
		[self stopAnimation];
}

- (void)pause
{
	if( [self currentProgress] == 1.0 || [self currentProgress] == 0.0 )
		return;
	
	if( [self isAnimating] )
		[self stopAnimation];
	else
		[self startAnimation];
	
}
@end

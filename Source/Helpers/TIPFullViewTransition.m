//
//  TIPFullViewTransition.m
//  TriviaPlayer
//
//  Created by Nur Monson on 10/20/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TIPFullViewTransition.h"

@interface TransitionAnimation : NSAnimation
@end

@implementation TIPFullViewTransition

- (id)init
{
	if( (self = [super init]) ) {
		startImage = nil;
		endImage = nil;
		//transitionFilter = [[CIFilter filterWithName:@"CICopyMachineTransition"] retain];
		transitionFilter = [[CIFilter filterWithName:@"CIDissolveTransition"] retain];
		[transitionFilter setDefaults];
		
		transitionLength = 0.0;
		startTime = 0.0;
		elapsedTime = 0.0;
		
		done = YES;
		ownerView = nil;
		
		animation = nil;
	}
	
	return self;
}

- (id)initWithStartImage:(CIImage *)aImage endImage:(CIImage *)bImage inTime:(NSTimeInterval)length forView:(NSView *)theView
{
	if( (self = [super init]) ) {
		
		startImage = [aImage retain];
		endImage = [bImage retain];
		
		transitionLength = length;
		startTime = 0.0;
		elapsedTime = 0.0;
		
		ownerView = theView;
		
		done = YES;
		
		transitionFilter = [[CIFilter filterWithName:@"CIDissolveTransition"] retain];
		if( transitionFilter == nil )
			printf("could not get proper filter!\n");
		
		[transitionFilter setDefaults];
		[transitionFilter setValue:startImage forKey:@"inputImage"];
		[transitionFilter setValue:endImage forKey:@"inputTargetImage"];
		cxt = nil;
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	if( startImage )
		[startImage release];
	if( endImage )
		[endImage release];
	
	if( transitionFilter )
		[transitionFilter release];
	
	if( cxt )
		[cxt release];
}

- (void)setStartImage:(CIImage *)theImage
{
		
	if( theImage == startImage )
		return;
	
	if( startImage )
		[startImage release];
	
	startImage = theImage;
	[startImage retain];
	
	[transitionFilter setValue:startImage forKey:@"inputImage"];
}
- (void)setEndImage:(CIImage *)theImage
{
	if( theImage == endImage )
		return;
	
	if( endImage )
		[endImage release];
	
	endImage = [theImage retain];
	
	[transitionFilter setValue:endImage forKey:@"inputTargetImage"];
}

- (void)setOwnerView:(NSView *)theView
{
	if( theView == ownerView )
		return;
	
	ownerView = theView;
}

- (void)startTransitionForSeconds:(NSTimeInterval)length
{
	if( ownerView == nil ) {
		printf("no view associated with transition filter!\n");
		return;
	}
	
	if( animation != nil ) {
		[animation stopAnimation];
		[animation release];
	}
	animation = [[TransitionAnimation alloc] initWithDuration:length animationCurve:NSAnimationEaseInOut];
	[animation setDelegate:self];
	done = NO;
	frameCounter = 0;
	[animation setAnimationBlockingMode:NSAnimationNonblocking];
	[animation startAnimation];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	if( aSelector == @selector(animationDidStop:) )
		return YES;
	
	return [super respondsToSelector:aSelector];
}

- (void)animationDidStop:(NSAnimation *)anAnimation
{
	done = YES;
}

- (void)animationTick
{
	[ownerView display];
}

- (BOOL)done
{
	return done;
}

- (void)drawInRect:(CGRect)theRect
{
	float animationTime;
	if( animation != nil )
		animationTime = [animation currentValue];
	else
		animationTime = 0.0f;
	
	[transitionFilter setValue:[NSNumber numberWithFloat:animationTime] forKey:@"inputTime"];
	
	CIImage *outputImage = [transitionFilter valueForKey:@"outputImage"];
	
	if( cxt == nil ) {
		NSDictionary *contextOptions = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool: NO],kCIContextUseSoftwareRenderer,nil];
		
		cxt = [CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort] options:contextOptions];
		[cxt retain];
	}
	[cxt drawImage:outputImage atPoint:theRect.origin fromRect:theRect];

	//[ownerView display];
	frameCounter++;
}
@end

@implementation TransitionAnimation

- (void)setCurrentProgress:(NSAnimationProgress)progress {
    [super setCurrentProgress:progress];
	
    [[self delegate] animationTick];
	if( progress == 1.0 )
		[self stopAnimation];
}


@end

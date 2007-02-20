//
//  TIPFullViewTransition.h
//  TriviaPlayer
//
//  Created by Nur Monson on 10/20/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface TIPFullViewTransition : NSObject {
	CIFilter *transitionFilter;
	CIImage *startImage;
	CIImage *endImage;
	CIContext *cxt;
	
	NSTimeInterval elapsedTime;
	NSTimeInterval startTime;
	NSTimeInterval transitionLength;
	
	NSAnimation *animation;

	NSView *ownerView;
	
	unsigned frameCounter;
	
	BOOL done;
}

// does not retain owner view.
- (id)initWithStartImage:(CIImage *)aImage endImage:(CIImage *)bImage inTime:(NSTimeInterval)length forView:(NSView *)theView;

- (void)setStartImage:(CIImage *)theImage;
- (void)setEndImage:(CIImage *)theImage;
- (void)setOwnerView:(NSView *)theView;

- (void)startTransitionForSeconds:(NSTimeInterval)length;
- (BOOL)done;

- (void)drawInRect:(CGRect)theRect;
@end

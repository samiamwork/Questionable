//
//  TriviaDrawableProgressTic.h
//  TriviaPlayer
//
//  Created by Nur Monson on 11/21/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaDrawable.h"
#import "TIPGradient.h"

@interface TriviaDrawableProgressTic : TriviaDrawable {
	TIPMutableGradientRef boxGradient;
	NSColor *bgColor;
}

- (NSColor *)backgroundColor;
- (void)setBackgroundColor:(NSColor *)aColor;
@end

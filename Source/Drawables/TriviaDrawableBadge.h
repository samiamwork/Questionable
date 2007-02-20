//
//  TriviaDrawablePlayerBadge.h
//  TriviaPlayer
//
//  Created by Nur Monson on 10/26/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaDrawable.h"
//#import "CTGradient.h"
#include "TIPGradient.h"
#import "TIPTextContainer.h"


@interface TriviaDrawableBadge : TriviaDrawable {
	//CTGradient *bgGradient;
	TIPMutableGradientRef bgGradient;
	NSString *theText;
	TIPTextContainer *textContainer;
	CGMutablePathRef outline;
}

- (void)setText:(NSString *)newText;
@end

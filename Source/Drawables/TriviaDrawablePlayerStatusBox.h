//
//  TriviaDrawablePlayerStatusBox.h
//  TriviaPlayer
//
//  Created by Nur Monson on 10/25/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaDrawable.h"
//#import "CTGradient.h"
#include "TIPGradient.h"


@interface TriviaDrawablePlayerStatusBox : TriviaDrawable {
	CGMutablePathRef pillBox;
	CGMutablePathRef shineBox;
	//CTGradient *boxGradient;
	//CTGradient *hilightGradient;
	TIPMutableGradientRef boxGradient;
	TIPMutableGradientRef hilightGradient;
}

@end

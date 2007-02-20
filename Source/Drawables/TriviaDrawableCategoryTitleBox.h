//
//  TriviaDrawableCategory.h
//  TriviaPlayer
//
//  Created by Nur Monson on 10/8/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaDrawable.h"
//#import "CTGradient.h"
#include "TIPGradient.h"

@interface TriviaDrawableCategoryTitleBox : TriviaDrawable {
	CGMutablePathRef box;
	//CTGradient *bgGradient;
	TIPMutableGradientRef bgGradient;
}

@end

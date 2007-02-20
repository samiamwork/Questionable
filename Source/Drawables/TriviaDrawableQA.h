//
//  TriviaDrawableQA.h
//  TriviaPlayer
//
//  Created by Nur Monson on 10/22/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaDrawable.h"
#import "TIPTextContainer.h"
//#import "CTGradient.h"
#include "TIPGradient.h"

@interface TriviaDrawableQA : TriviaDrawable {
	TIPTextContainer *titleContainer;
	NSString *titleString;
	TIPTextContainer *textContainer;
	NSString *textString;
	NSRect titleRect;
	NSRect textRect;
	
	//CTGradient *blackShine;
	//CTGradient *textGradient;
	//CTGradient *titleGradient;
	TIPGradientRef blackShine;
	TIPMutableGradientRef textGradient;
	TIPMutableGradientRef titleGradient;
	
	CGMutablePathRef titleBox;
	CGMutablePathRef textBox;
}

- (void)setTitle:(NSString *)newTitle;
- (NSString *)title;
- (void)setText:(NSString *)newText;
- (NSString *)text;
@end

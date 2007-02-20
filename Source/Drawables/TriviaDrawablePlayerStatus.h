//
//  TriviaDrawablePlayerStatus.h
//  TriviaPlayer
//
//  Created by Nur Monson on 10/20/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaDrawable.h"
#import "TriviaPlayer.h"
#import "TIPTextContainer.h"
//#import "CTGradient.h"
#include "TIPGradient.h"
#import "TriviaDrawablePlayerStatusBox.h"

@interface TriviaDrawablePlayerStatus : TriviaDrawable {
	NSMutableArray *players;
	
	TIPTextContainer *nameContainer;
	TIPTextContainer *pointContainer;
	
	//CTGradient *blackShine;
	TIPGradientRef blackShine;
	TriviaDrawablePlayerStatusBox *playerBox;
}

- (void)setPlayers:(NSArray *)newPlayers;
- (NSArray *)players;
@end

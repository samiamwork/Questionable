//
//  TriviaScenePlayers.h
//  Questionable
//
//  Created by Nur Monson on 7/14/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RectangularBox.h"
#import "StringTexture.h"

@interface TriviaScenePlayers : NSObject <TextureScaling> {
	NSSize _size;
	float _scale;
	
	RectangularBox *_playerNameBox;
	RectangularBox *_playerPointBox;
	NSMutableArray *_playerNameStrings;
	NSMutableArray *_playerPointStrings;
	
	NSSize _playerNameSize;
	NSSize _playerPointSize;
	float _playerPointPadding;
}

- (void)setPlayers:(NSArray *)newPlayers;
@end

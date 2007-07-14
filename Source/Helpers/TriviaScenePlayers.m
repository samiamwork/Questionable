//
//  TriviaScenePlayers.m
//  Questionable
//
//  Created by Nur Monson on 7/14/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TriviaScenePlayers.h"
#import "TriviaPlayer.h"

@implementation TriviaScenePlayers

- (id)init
{
	if( (self = [super init]) ) {
		_scale = 1.0f;
		
		_playerNameBox = [[RectangularBox alloc] init];
		[_playerNameBox setSharpCorners:BoxCornerAll];
		[_playerNameBox setLineWidth:1.0f];
		[_playerNameBox setCornerRadius:5.0f];
		_playerPointBox = [[RectangularBox alloc] init];
		[_playerPointBox setSharpCorners:BoxCornerUpperLeft|BoxCornerUpperRight|BoxCornerLowerLeft];
		[_playerPointBox setLineWidth:1.0f];
		[_playerPointBox setCornerRadius:5.0f];
		_playerNameStrings = [[NSMutableArray alloc] init];
		_playerPointStrings = [[NSMutableArray alloc] init];
		
		[self setSize:NSMakeSize(640.0f,480.0f)];
	}

	return self;
}

- (void)dealloc
{
	[_playerNameBox release];
	[_playerPointBox release];
	[_playerNameStrings release];
	[_playerPointStrings release];

	[super dealloc];
}

- (void)setPlayers:(NSArray *)newPlayers
{
	NSMutableArray *topScorers = [NSMutableArray arrayWithArray:newPlayers];
	[topScorers sortUsingSelector:@selector(sortByPoints:)];
	
	while( [topScorers count] > 4 )
		[topScorers removeObjectAtIndex:4];
	
	NSEnumerator *playerEnumerator = [topScorers objectEnumerator];
	TriviaPlayer *aPlayer;
	while( (aPlayer = [playerEnumerator nextObject]) ) {
		StringTexture *aNameTexture = [[StringTexture alloc] initWithString:[aPlayer name] withSize:[_playerNameBox size] withFontSize:ceilf([_playerNameBox size].height*0.8f)];
		[[aNameTexture textContainer] setTruncates:YES];
		[aNameTexture setFontSize:ceilf([_playerNameBox size].height*0.7f)];
		[aNameTexture setScale:_scale];
		[_playerNameStrings addObject:aNameTexture];
		StringTexture *aPointTexture = [[StringTexture alloc] initWithString:[NSString stringWithFormat:@"%d",[aPlayer points]] withSize:[_playerNameBox size] withFontSize:ceilf([_playerPointBox size].height*0.8f)];
		[aPointTexture setScale:_scale];
		[_playerPointStrings addObject:aPointTexture];
	}
}

#pragma mark Texture Scaling

- (void)setScale:(float)newScale
{
	if( newScale == _scale )
		return;
	
	[_playerNameBox setScale:_scale];
	[_playerPointBox setScale:_scale];
	
	// there are always the same amount of point strings as there are player names
	// so we can do them together
	unsigned int playerIndex;
	for( playerIndex = 0; playerIndex < [_playerNameStrings count]; playerIndex++ ) {
		[[_playerNameStrings objectAtIndex:playerIndex] setScale:_scale];
		[[_playerPointStrings objectAtIndex:playerIndex] setScale:_scale];
	}
	
}

#define BOARDMARGINS ((NSSize){10.0f, 25.0f})
- (void)setSize:(NSSize)newSize
{
	if( NSEqualSizes(newSize,_size) )
		return;
	
	_size = newSize;
	
	_playerNameSize = NSMakeSize(_size.width-2.0f*BOARDMARGINS.width,ceilf(((_size.height-BOARDMARGINS.height*2.0f)/4.0f)*0.5f));
	_playerPointSize = NSMakeSize(_playerNameSize.width,ceilf(((_size.height-BOARDMARGINS.height*2.0f)/4.0f)*0.3f));
	_playerPointPadding = ceilf(((_size.height-BOARDMARGINS.height*2.0f)/4.0f)*0.2f);
	[_playerNameBox setSize:_playerNameSize];
	[_playerPointBox setSize:_playerPointSize];
	[_playerPointBox setCornerRadius:ceilf(_playerPointSize.height*0.4f)];
	
	NSEnumerator *stringEnumerator = [_playerNameStrings objectEnumerator];
	StringTexture *aStringTexture;
	while( (aStringTexture = [stringEnumerator nextObject]) ) {
		[aStringTexture setSize:[_playerNameBox size]];
		[aStringTexture setFontSize:ceilf([_playerNameBox size].height*0.8f)];
	}
	
	NSEnumerator *pointEnumerator = [_playerPointStrings objectEnumerator];
	while( (aStringTexture = [pointEnumerator nextObject]) ) {
		[aStringTexture setSize:[_playerPointBox size]];
		[aStringTexture setFontSize:ceilf([_playerPointBox size].height*0.7f)];
	}

}
- (NSSize)size
{
	return _size;
}

- (void)buildTexture
{
	[_playerNameBox buildTexture];
	[_playerPointBox buildTexture];
	[_playerNameStrings makeObjectsPerformSelector:@selector(buildTexture)];
	[_playerPointStrings makeObjectsPerformSelector:@selector(buildTexture)];
}

- (void)draw
{
	glTranslatef(BOARDMARGINS.width,_size.height-BOARDMARGINS.height-[_playerNameBox size].height,0.0f);
	unsigned int playerIndex;
	for( playerIndex = 0; playerIndex < [_playerNameStrings count] && playerIndex < 4; playerIndex++ ) {
		[_playerNameBox drawWithString:[_playerNameStrings objectAtIndex:playerIndex]];
		glTranslatef(0.0f,-[_playerPointBox size].height,0.0f);
		[_playerPointBox drawWithString:[_playerPointStrings objectAtIndex:playerIndex]];
		glTranslatef(0.0f,-([_playerNameBox size].height+_playerPointPadding),0.0f);
	}
}
@end

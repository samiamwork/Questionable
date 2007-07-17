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
		[_playerNameBox setSharpCorners:BoxCornerUpperRight|BoxCornerLowerRight];
		[_playerNameBox setStartColor:[NSColor colorWithCalibratedRed:92.0f/255.0f green:142.0f/255.0f blue:251.0f/255.0f alpha:1.0f]];
		[_playerNameBox setEndColor:[NSColor colorWithCalibratedRed:46.0f/255.0f green:83.0f/255.0f blue:145.0f/255.0f alpha:1.0f]];
		[_playerNameBox setLineWidth:1.0f];
		[_playerNameBox setCornerRadius:5.0f];
		_playerPointBox = [[RectangularBox alloc] init];
		[_playerPointBox setSharpCorners:BoxCornerUpperLeft|BoxCornerLowerLeft];
		[_playerPointBox setLineWidth:1.0f];
		[_playerPointBox setCornerRadius:5.0f];
		
		_shine = [[RectangularBox alloc] init];
		[_shine setStartColor:[NSColor colorWithCalibratedWhite:1.0f alpha:0.05f]];
		[_shine setEndColor:[NSColor colorWithCalibratedWhite:1.0f alpha:0.5f]];
		[_shine setSharpCorners:BoxCornerLowerLeft | BoxCornerLowerRight];
		[_shine enableBorder:NO];
		
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
	[_shine release];
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
		StringTexture *aPointTexture = [[StringTexture alloc] initWithString:[NSString stringWithFormat:@"%d",[aPlayer points]] withSize:[_playerNameBox size] withFontSize:ceilf([_playerPointBox size].height*0.5f)];
		[aPointTexture setScale:_scale];
		[aPointTexture setColor:[NSColor whiteColor]];
		[_playerPointStrings addObject:aPointTexture];
	}
}

#pragma mark Texture Scaling

- (void)setScale:(float)newScale
{
	if( newScale == _scale )
		return;
	
	_scale = newScale;
	[_playerNameBox setScale:_scale];
	[_playerPointBox setScale:_scale];
	[_shine setScale:_scale];
	
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
	
	NSSize availableSize = NSMakeSize(_size.width-2.0f*BOARDMARGINS.width, _size.height - 2.0f*BOARDMARGINS.height);
	//_playerNameSize = NSMakeSize(_size.width-2.0f*BOARDMARGINS.width,ceilf(((_size.height-BOARDMARGINS.height*2.0f)/4.0f)*0.5f));
	//_playerPointSize = NSMakeSize(_playerNameSize.width,ceilf(((_size.height-BOARDMARGINS.height*2.0f)/4.0f)*0.3f));
	_playerNameSize = NSMakeSize(availableSize.width*0.7f,ceilf(((_size.height-BOARDMARGINS.height*2.0f)/4.0f)*0.8f));
	_playerPointSize = NSMakeSize(availableSize.width*0.3f,_playerNameSize.height);
	_playerPointPadding = ceilf(((_size.height-BOARDMARGINS.height*2.0f)/4.0f)*0.2f);
	[_playerNameBox setSize:_playerNameSize];
	[_playerNameBox setCornerRadius:ceilf(_playerPointSize.height*0.3f)];
	[_playerPointBox setSize:_playerPointSize];
	[_playerPointBox setCornerRadius:[_playerNameBox cornerRadius]];
	
	[_shine setSize:NSMakeSize(availableSize.width*0.965f,_playerNameSize.height*0.4f)];
	[_shine setCornerRadius:[_playerNameBox cornerRadius]*0.8f];
	
	NSEnumerator *stringEnumerator = [_playerNameStrings objectEnumerator];
	StringTexture *aStringTexture;
	while( (aStringTexture = [stringEnumerator nextObject]) ) {
		[aStringTexture setSize:[_playerNameBox size]];
		[aStringTexture setFontSize:ceilf([_playerNameBox size].height*0.8f)];
	}
	
	NSEnumerator *pointEnumerator = [_playerPointStrings objectEnumerator];
	while( (aStringTexture = [pointEnumerator nextObject]) ) {
		[aStringTexture setSize:[_playerPointBox size]];
		[aStringTexture setFontSize:ceilf([_playerPointBox size].height*0.5f)];
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
	[_shine buildTexture];
	[_playerNameStrings makeObjectsPerformSelector:@selector(buildTexture)];
	[_playerPointStrings makeObjectsPerformSelector:@selector(buildTexture)];
}

- (void)draw
{
	glTranslatef(BOARDMARGINS.width,_size.height-BOARDMARGINS.height-[_playerNameBox size].height,0.0f);
	unsigned int playerIndex;
	for( playerIndex = 0; playerIndex < [_playerNameStrings count] && playerIndex < 4; playerIndex++ ) {
		glPushMatrix();
		[_playerNameBox drawWithString:[_playerNameStrings objectAtIndex:playerIndex]];
		glTranslatef([_playerNameBox size].width,0.0f,0.0f);
		[_playerPointBox drawWithString:[_playerPointStrings objectAtIndex:playerIndex]];
		glPopMatrix();
		glPushMatrix();
		glTranslatef(([_playerNameBox size].width+[_playerPointBox size].width-[_shine size].width)/2.0f,([_playerNameBox size].height-[_shine size].height)*0.95f,0.0f);
		[_shine draw];
		glPopMatrix();
		glTranslatef(0.0f,-([_playerNameBox size].height+_playerPointPadding),0.0f);
	}
}
@end

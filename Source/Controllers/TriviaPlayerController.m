//
//  TriviaPlayerController.m
//  TriviaPlayer
//
//  Created by Nur Monson on 9/25/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaPlayerController.h"


@implementation TriviaPlayerController

- (id)init
{
	if( (self = [super init]) ) {

		players = [[NSMutableArray alloc] init];
		[self addPlayer:nil];
		
		NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"points" ascending:NO] autorelease];
		sortDescriptors = [[NSArray alloc] initWithObjects:descriptor,nil];

		_getInputWindow = [[TriviaPlayerGetInputController alloc] init];
		
		[self addObserver:self forKeyPath:@"players" options:NSKeyValueObservingOptionOld context:nil];
		[[TIPInputManager defaultManager] setDelegate:self];
	}
	
	return self;
}

- (void)dealloc
{
	[players release];
	[sortDescriptors release];
	[self removeObserver:self forKeyPath:@"players"];

	[_getInputWindow release];
	
	[super dealloc];
}

- (id)delegate
{
	return _delegate;
}
- (void)setDelegate:(id)newDelegate
{
	_delegate = newDelegate;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// because I have to
}

- (void)willChange:(NSKeyValueChange)change valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key
{
	if( [key isEqualToString:@"players"] && change == NSKeyValueChangeRemoval ) {
		
		TriviaPlayer *playerToRemove;
		NSUInteger currentIndex = [indexes firstIndex];
		while( currentIndex != NSNotFound ) {
			playerToRemove = [players objectAtIndex:currentIndex];
			//if( infoController && playerToRemove == [infoController player] )
			//	[infoController setPlayer:nil];
			
			currentIndex = [indexes indexGreaterThanIndex:currentIndex];
		}
		
	}
}

- (NSMutableArray *)players
{
	return players;
}
- (void)setPlayers:(NSArray *)newPlayers
{
	if(newPlayers != players) {
		[players autorelease];
		players = [[NSMutableArray alloc] initWithArray:newPlayers];
	}
}

- (NSArray *)sortDescriptors
{
	return sortDescriptors;
}

- (IBAction)addPlayer:(id)sender
{
	TriviaPlayer *newPlayer = [[TriviaPlayer alloc] init];
	[newPlayer setName:[NSString stringWithFormat:@"Player %d", [players count]+1]];
	
	[players addObject:newPlayer];

	// tell the object controllers that it's changed
	[self setPlayers:players];
	[playerArrayController setSelectionIndex:[players count]-1];
}

- (IBAction)removePlayer:(id)sender
{
	NSArray *selectedPlayers = [playerArrayController selectedObjects];
	
	NSEnumerator *playerEnumerator = [selectedPlayers objectEnumerator];
	TriviaPlayer *aPlayer;
	while( (aPlayer = [playerEnumerator nextObject]) )
		[players removeObject:aPlayer];
	
	if( [players count] == 0 )
		[self addPlayer:nil];
	
	// tell the object controllers that it's changed
	[self setPlayers:players];
}

- (BOOL)allDisabled
{
	NSEnumerator *playerEnumerator = [players objectEnumerator];
	TriviaPlayer *aPlayer;
	
	while( (aPlayer = [playerEnumerator nextObject]) ) {
		if( [aPlayer enabled] )
			return NO;
	}
	
	return YES;
}
- (void)disableAllPlayers
{
	NSEnumerator *playerEnumerator = [players objectEnumerator];
	TriviaPlayer *aPlayer;
	/*
	if( inputPollTimer )
		[inputPollTimer invalidate];
	inputPollTimer = nil;
	*/
	while( (aPlayer = [playerEnumerator nextObject]) ) {
		[aPlayer setEnabled:NO];
	}
}
- (void)enableAllPlayers
{
	NSEnumerator *playerEnumerator = [players objectEnumerator];
	TriviaPlayer *aPlayer;
	while( (aPlayer = [playerEnumerator nextObject]) )
		[aPlayer setEnabled:YES];
}

- (IBAction)registerInput:(id)sender
{	
	NSUInteger selectionIndex = [playerArrayController selectionIndex];
	if( selectionIndex == NSNotFound)
		return;
	
	[_getInputWindow setPromptStringForPlayerName:[[players objectAtIndex:selectionIndex] name]];

	[[TIPInputManager defaultManager] getAnyElementWithTimeout:5.0];
	[_getInputWindow beginModalStatus];
}

- (void)elementSearchFinished:(TIPInputElement*)foundElement
{
	[_getInputWindow endModalStatus];

	TriviaPlayer *thePlayer = [players objectAtIndex:[playerArrayController selectionIndex]];
	if( foundElement == nil || thePlayer  == nil)
		return;

	[thePlayer setInputElement:foundElement];

	unsigned int selectedPlayerIndex = [playerArrayController selectionIndex];
	unsigned int originalSelectedPlayer = selectedPlayerIndex;
	
	do {
		selectedPlayerIndex++;
		if( selectedPlayerIndex >= [players count] )
			selectedPlayerIndex = 0;
	} while( selectedPlayerIndex != originalSelectedPlayer && [[players objectAtIndex:selectedPlayerIndex] connected] );
	
	if( selectedPlayerIndex != originalSelectedPlayer )
		[playerArrayController setSelectionIndex:selectedPlayerIndex];
	
}

- (void)inputManager:(TIPInputManager*)inputManager elementPressed:(TIPInputElement*)element
{
	for(TriviaPlayer* aPlayer in players)
	{
		if([aPlayer inputElement] == element)
		{
			[aPlayer setPressed:YES];
			if([aPlayer enabled] && _delegate != nil && [_delegate respondsToSelector:@selector(playerBuzzed:)])
			{
				[_delegate playerBuzzed:aPlayer];
			}
			break;
		}
	}
}

- (void)inputManager:(TIPInputManager *)inputManager elementReleased:(TIPInputElement *)element
{
	for(TriviaPlayer* aPlayer in players)
	{
		if([aPlayer inputElement] == element)
		{
			[aPlayer setPressed:NO];
			break;
		}
	}
}
@end

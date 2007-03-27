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
		inputPollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(checkForBuzz:) userInfo:nil repeats:YES];
		
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
	[inputPollTimer invalidate];
	
	[_getInputWindow release];
	
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// because I have to
}

- (void)willChange:(NSKeyValueChange)change valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key
{	
	if( [key isEqualToString:@"players"] && change == NSKeyValueChangeRemoval ) {
		
		TriviaPlayer *playerToRemove;
		unsigned currentIndex = [indexes firstIndex];
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

- (void)checkForBuzz:(NSTimer *)aTimer
{
	NSEnumerator *playerEnumerator = [players objectEnumerator];
	TriviaPlayer *aPlayer;
	while( (aPlayer = [playerEnumerator nextObject]) ) {
		if( [aPlayer isButtonPressed] )
			return;
	}
}
- (IBAction)registerInput:(id)sender
{	
	unsigned int selectionIndex = [playerArrayController selectionIndex];
	if( selectionIndex == NSNotFound || _waitingForButton )
		return;
	
	[_getInputWindow setPromptStringForPlayerName:[[players objectAtIndex:selectionIndex] name]];
	_playerToGetButtonFor = [players objectAtIndex:selectionIndex];
	[_playerToGetButtonFor retain];
	_waitingForButton = YES;
	
	[[TIPInputManager defaultManager] getAnyElementWithTimeout:5.0];
	[_getInputWindow beginModalStatus];
}

- (void)elementSearchFinished:(TIPInputElement *)foundElement
{
	_waitingForButton = NO;
	[_getInputWindow endModalStatus];
	if( foundElement == nil || _playerToGetButtonFor == nil )
		return;
	
	[_playerToGetButtonFor setInputElement:foundElement];
	[_playerToGetButtonFor release];
	_playerToGetButtonFor = nil;
}
@end

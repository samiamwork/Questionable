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
		NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"points" ascending:NO] autorelease];
		sortDescriptors = [[NSArray alloc] initWithObjects:descriptor,nil];
		inputPollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(checkForBuzz:) userInfo:nil repeats:YES];
		
		[self addObserver:self forKeyPath:@"players" options:NSKeyValueObservingOptionOld context:nil];
	}
	
	return self;
}

- (void)dealloc
{
	[players release];
	[sortDescriptors release];
	[self removeObserver:self forKeyPath:@"players"];
	[inputPollTimer invalidate];
	
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
	if( selectionIndex == NSNotFound )
		return;
	
	[sender setEnabled:NO];
	[[players objectAtIndex:selectionIndex] registerInput];
	[sender setEnabled:YES];
}
@end

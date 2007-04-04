//
//  TriviaPlayerGetInputController.m
//  Questionable
//
//  Created by Nur Monson on 3/26/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TriviaPlayerGetInputController.h"


@implementation TriviaPlayerGetInputController

- (id)init
{
	if( (self = [super initWithWindowNibName:@"GetInput"]) ) {
		[self setPromptStringForPlayerName:@"Player 1"];
	}

	return self;
}

- (void)dealloc
{
	[_promptString release];

	[super dealloc];
}

#pragma mark Accessors

- (void)setPromptStringForPlayerName:(NSString *)playerName
{
	if( playerName == nil )
		return;
	
	[_promptString release];
	_promptString = [[NSString alloc] initWithFormat:NSLocalizedString(@"Press any button to use as a buzzer for %@.",@"Player button configure prompt"),playerName];
}

- (void)beginModalStatus
{
	if( [self window] == nil )
		[NSBundle loadNibNamed:@"GetInput" owner:self];
	
	[_spinner setIndeterminate:YES];
	[_spinner startAnimation:self];
	[_promptField setStringValue:_promptString];
	
	[NSApp runModalForWindow:[self window]];
}

- (void)endModalStatus
{
	[[self window] orderOut:nil];
	
	[_spinner stopAnimation:self];
	
	[NSApp abortModal];
}
@end

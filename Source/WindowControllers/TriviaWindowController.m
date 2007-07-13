//
//  TriviaWindowController.m
//  TriviaPlayer
//
//  Created by Nur Monson on 11/3/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaWindowController.h"
#import "TriviaSoundController.h"

static NSString *TriviaToolbarIdentifier = @"Trivia Toolbar Identifier";
static NSString *TriviaToolbarItemIdentifierPlay = @"Trivia Toolbar Item Identifier Play";
static NSString *TriviaToolbarItemIdentifierStop = @"Trivia Toolbar Item Identifier Stop";
static NSString *TriviaToolbarItemIdentifierTimer = @"Trivia Toolbar Item Identifier Timer";
static NSString *TriviaToolbarItemIdentifierQuestionsTab = @"Trivia Toolbar Item Identifier Questions Tab";
static NSString *TriviaToolbarItemIdentifierPlayersTab = @"Trivia Toolbar Item Identifier Players Tab";
static NSString *TriviaToolbarItemIdentifierControlsTab = @"Trivia Toolbar Item Identifier Controls Tab";

@interface TriviaWindowController (Private)
- (void)setupToolbar;
@end

@implementation TriviaWindowController

- (id)init {
	if( (self = [super init]) ) {
		fullscreenController = [[FullscreenSheetController alloc] init];
		playToolbarItem = nil;
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	[fullscreenController release];
}

- (void)awakeFromNib
{
	[[self window] setExcludedFromWindowsMenu:YES];
	[gameWindow setExcludedFromWindowsMenu:YES];
	
	[[self window] setDelegate:self];
	[gameWindow setDelegate:self];
	[self setupToolbar];
	
	[gameController setDelegate:self];
}

- (void)setupToolbar
{
	NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:TriviaToolbarIdentifier] autorelease];
	
	[toolbar setAllowsUserCustomization:NO];
	[toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
	
	[toolbar setDelegate:self];
	[toolbar setSelectedItemIdentifier:TriviaToolbarItemIdentifierControlsTab];
	
	[[self window] setToolbar:toolbar];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdent willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
	NSToolbarItem *toolbarItem = nil;
	
	if( [itemIdent isEqual:TriviaToolbarItemIdentifierPlay] ) {
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:TriviaToolbarItemIdentifierPlay] autorelease];
		[toolbarItem setLabel:NSLocalizedString(@"Play",@"Play")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"Play",@"Play")];
		[toolbarItem setImage:[NSImage imageNamed:@"Play"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(play:)];
		playToolbarItem = toolbarItem;
	} else if( [itemIdent isEqual:TriviaToolbarItemIdentifierStop] ) {
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:TriviaToolbarItemIdentifierStop] autorelease];
		[toolbarItem setLabel:NSLocalizedString(@"Stop",@"Stop")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"Stop",@"Stop")];
		[toolbarItem setImage:[NSImage imageNamed:@"Stop"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(stop:)];
	} else if( [itemIdent isEqual:TriviaToolbarItemIdentifierTimer] ) {
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:TriviaToolbarItemIdentifierTimer] autorelease];
		[toolbarItem setLabel:NSLocalizedString(@"Timer",@"Timer")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"Timer",@"Timer")];
		[toolbarItem setMinSize:NSMakeSize(45.0f,45.0f)];
		[toolbarItem setMaxSize:NSMakeSize(45.0f,45.0f)];
		[toolbarItem setView:gameTimerView];
	} else if( [itemIdent isEqual:TriviaToolbarItemIdentifierControlsTab] ) {
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:TriviaToolbarItemIdentifierControlsTab] autorelease];
		[toolbarItem setLabel:NSLocalizedString(@"Controls",@"Controls")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"Controls",@"Controls")];
		[toolbarItem setImage:[NSImage imageNamed:@"controls.tif"]];
		controlsItem = toolbarItem;
		//[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(pickTab:)];
	} else if( [itemIdent isEqual:TriviaToolbarItemIdentifierQuestionsTab] ) {
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:TriviaToolbarItemIdentifierQuestionsTab] autorelease];
		[toolbarItem setLabel:NSLocalizedString(@"Questions",@"Questions")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"Questions",@"Questions")];
		[toolbarItem setImage:[NSImage imageNamed:@"questionsOff.tif"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(pickTab:)];
		questionsItem = toolbarItem;
	} else if( [itemIdent isEqual:TriviaToolbarItemIdentifierPlayersTab] ) {
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:TriviaToolbarItemIdentifierPlayersTab] autorelease];
		[toolbarItem setLabel:NSLocalizedString(@"Players",@"Players")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"Players",@"Players")];
		[toolbarItem setImage:[NSImage imageNamed:@"playersOff.tif"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(pickTab:)];
		playersItem = toolbarItem;
	} else {
		toolbarItem = nil;
	}

	return toolbarItem;
}

- (void)pickTab:(NSToolbarItem *)clickedTab
{
	if( clickedTab == controlsItem ) {
		[controlsItem setTarget:nil];
		[controlsItem setImage:[NSImage imageNamed:@"controls.tif"]];
		
		[questionsItem setTarget:self];
		[questionsItem setImage:[NSImage imageNamed:@"questionsOff.tif"]];
		
		[playersItem setTarget:self];
		[playersItem setImage:[NSImage imageNamed:@"playersOff.tif"]];
		
		[_controlTabs selectTabViewItemAtIndex:0];
	} else if( clickedTab == questionsItem ) {
		[questionsItem setTarget:nil];
		[questionsItem setImage:[NSImage imageNamed:@"questions.tif"]];
		
		[controlsItem setTarget:self];
		[controlsItem setImage:[NSImage imageNamed:@"controlsOff.tif"]];
		
		[playersItem setTarget:self];
		[playersItem setImage:[NSImage imageNamed:@"playersOff.tif"]];
		
		[_controlTabs selectTabViewItemAtIndex:1];
	} else if( clickedTab == playersItem ) {
		[playersItem setTarget:nil];
		[playersItem setImage:[NSImage imageNamed:@"players.tif"]];
		
		[questionsItem setTarget:self];
		[questionsItem setImage:[NSImage imageNamed:@"questionsOff.tif"]];
		
		[controlsItem setTarget:self];
		[controlsItem setImage:[NSImage imageNamed:@"controlsOff.tif"]];
		
		[_controlTabs selectTabViewItemAtIndex:2];
	}

}

- (IBAction)menuPickTab:(id)sender
{
	int tag = [(NSMenuItem *)sender tag];
	NSToolbarItem *itemToSelect = nil;
	switch( tag ) {
		case 1:
			itemToSelect = controlsItem;
			break;
		case 2:
			itemToSelect = questionsItem;
			break;
		case 3:
			itemToSelect = playersItem;
			break;
		default:
			return;
	}
	
	[self pickTab:itemToSelect];
	[[[self window] toolbar] setSelectedItemIdentifier:[itemToSelect itemIdentifier]];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:TriviaToolbarItemIdentifierControlsTab,
		TriviaToolbarItemIdentifierPlayersTab,
		TriviaToolbarItemIdentifierQuestionsTab,nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects: TriviaToolbarItemIdentifierControlsTab,
		TriviaToolbarItemIdentifierQuestionsTab, TriviaToolbarItemIdentifierPlayersTab,
		NSToolbarFlexibleSpaceItemIdentifier, TriviaToolbarItemIdentifierTimer,
		TriviaToolbarItemIdentifierPlay,
		TriviaToolbarItemIdentifierStop, nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [self toolbarDefaultItemIdentifiers:toolbar];
}

- (void)toolbarDidRemoveItem:(NSNotification *)theNotification
{
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
	return YES;
}

#pragma mark toolbar actions
- (IBAction)toggleSound:(id)sender
{
	if( [[TriviaSoundController defaultController] mute] ) {
		[[TriviaSoundController defaultController] setMute:NO];
	} else {
		[[TriviaSoundController defaultController] setMute:YES];
	}
}

- (IBAction)toggleFullscreen:(id)sender
{
	[fullscreenController setAttachedWindow:gameWindow];
	[fullscreenController toggleFullscreen];
}

- (IBAction)play:(id)sender
{
	if( ![gameController startRound] )
		return;
	
	[playToolbarItem setImage:[NSImage imageNamed:@"Pause"]];
	[playToolbarItem setLabel:@"Pause"];
	[playToolbarItem setAction:@selector(pause:)];
	
	[playMenuItem setTitle:@"Pause"];
	[playMenuItem setAction:@selector(pause:)];
	
	[self pickTab:controlsItem];
}

- (void)resetPlayButtons
{
	[playToolbarItem setImage:[NSImage imageNamed:@"Play"]];
	[playToolbarItem setLabel:@"Play"];
	[playToolbarItem setAction:@selector(play:)];
	
	[playMenuItem setTitle:@"Play"];
	[playMenuItem setAction:@selector(play:)];
}

- (IBAction)pause:(id)sender
{
	[gameController pauseRound];
	[self resetPlayButtons];
}

- (IBAction)stop:(id)sender
{
	[gameController stopRound];
	[self resetPlayButtons];
}

- (void)load:(id)sender
{
	[questionController openGame:self];
}

- (void)willStopGame:(TriviaGameController *)aGameController
{
	[self resetPlayButtons];
}

- (void)willPauseGame:(TriviaGameController *)aGameController
{
	[playToolbarItem setImage:[NSImage imageNamed:@"Pause"]];
	[playToolbarItem setLabel:@"Pause"];
	[playToolbarItem setAction:@selector(pause:)];
	
	[playMenuItem setTitle:@"Pause"];
	[playMenuItem setAction:@selector(pause:)];
}

@end

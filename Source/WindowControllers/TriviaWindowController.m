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
static NSString *TriviaToolbarItemIdentifierMute = @"Trivia Toolbar Item Identifier Mute";
static NSString *TriviaToolbarItemIdentifierFullscreen = @"Trivia Toolbar Item Identifier Fullscreen";
static NSString *TriviaToolbarItemIdentifierLoad = @"Trivia Toolbar Item Identifier Load";
static NSString *TriviaToolbarItemIdentifierPlay = @"Trivia Toolbar Item Identifier Play";
static NSString *TriviaToolbarItemIdentifierStop = @"Trivia Toolbar Item Identifier Stop";
static NSString *TriviaToolbarItemIdentifierTimer = @"Trivia Toolbar Item Identifier Timer";

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
}

- (void)setupToolbar
{
	NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:TriviaToolbarIdentifier] autorelease];
	
	[toolbar setAllowsUserCustomization:NO];
	[toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
	
	[toolbar setDelegate:self];
	
	[[self window] setToolbar:toolbar];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdent willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
	NSToolbarItem *toolbarItem = nil;
	
	if( [itemIdent isEqual:TriviaToolbarItemIdentifierMute] ) {
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:TriviaToolbarItemIdentifierMute] autorelease];
		[toolbarItem setLabel:NSLocalizedString(@"Sound",@"Sound")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"Sound",@"Sound")];
		[toolbarItem setImage:[NSImage imageNamed:@"Sound.tiff"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(toggleSound:)];
	} else if( [itemIdent isEqual:TriviaToolbarItemIdentifierLoad] ) {
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:TriviaToolbarItemIdentifierLoad] autorelease];
		[toolbarItem setLabel:NSLocalizedString(@"Load",@"Load")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"Load",@"Load")];
		[toolbarItem setImage:[NSImage imageNamed:@"loadQuestions.tiff"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(load:)];
	} else if( [itemIdent isEqual:TriviaToolbarItemIdentifierFullscreen] ) {
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:TriviaToolbarItemIdentifierFullscreen] autorelease];
		[toolbarItem setLabel:NSLocalizedString(@"Fullscreen",@"Fullscreen")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"Fullscreen",@"Fullscreen")];
		[toolbarItem setImage:[NSImage imageNamed:@"fullscreenIcon.tiff"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(toggleFullscreen:)];
	} else if( [itemIdent isEqual:TriviaToolbarItemIdentifierPlay] ) {
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:TriviaToolbarItemIdentifierPlay] autorelease];
		[toolbarItem setLabel:NSLocalizedString(@"Play",@"Play")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"Play",@"Play")];
		[toolbarItem setImage:[NSImage imageNamed:@"Play"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(play:)];
		playToolbarItem = toolbarItem;
	} else if( [itemIdent isEqual:TriviaToolbarItemIdentifierStop] ) {
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:TriviaToolbarItemIdentifierPlay] autorelease];
		[toolbarItem setLabel:NSLocalizedString(@"Stop",@"Stop")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"Stop",@"Stop")];
		[toolbarItem setImage:[NSImage imageNamed:@"Stop"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(stop:)];
	} else if( [itemIdent isEqual:TriviaToolbarItemIdentifierTimer] ) {
		toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:TriviaToolbarItemIdentifierPlay] autorelease];
		[toolbarItem setLabel:NSLocalizedString(@"Timer",@"Timer")];
		[toolbarItem setPaletteLabel:NSLocalizedString(@"Timer",@"Timer")];
		[toolbarItem setMinSize:NSMakeSize(45.0f,45.0f)];
		[toolbarItem setMaxSize:NSMakeSize(45.0f,45.0f)];
		[toolbarItem setView:gameTimerView];
	} else {
		toolbarItem = nil;
	}

	return toolbarItem;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects: TriviaToolbarItemIdentifierMute,
		TriviaToolbarItemIdentifierLoad, TriviaToolbarItemIdentifierFullscreen,
		NSToolbarFlexibleSpaceItemIdentifier, TriviaToolbarItemIdentifierTimer,
		NSToolbarFlexibleSpaceItemIdentifier, TriviaToolbarItemIdentifierPlay,
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
- (void)toggleSound:(id)sender
{
	if( [[TriviaSoundController defaultController] mute] ) {
		[[TriviaSoundController defaultController] setMute:NO];
		[sender setImage:[NSImage imageNamed:@"Sound.tiff"]];
		//[sender setLabel:@"Mute"];
	} else {
		[[TriviaSoundController defaultController] setMute:YES];
		[sender setImage:[NSImage imageNamed:@"NoSound.tiff"]];
		//[sender setLabel:@"Unmute"];
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
	
	[sender setImage:[NSImage imageNamed:@"Pause"]];
	[sender setLabel:@"Pause"];
	[sender setAction:@selector(pause:)];
}

- (IBAction)pause:(id)sender
{
	[gameController pauseRound];
	[sender setImage:[NSImage imageNamed:@"Play"]];
	[sender setLabel:@"Play"];
	[sender setAction:@selector(play:)];
}

- (IBAction)stop:(id)sender
{
	[gameController stopRound];
	if( playToolbarItem != nil && [[playToolbarItem label] isEqualToString:@"Pause"] ) {
		[playToolbarItem setImage:[NSImage imageNamed:@"Play"]];
		[playToolbarItem setLabel:@"Play"];
		[playToolbarItem setAction:@selector(play:)];
	}
}

- (void)load:(id)sender
{
	[questionController openGame:self];
}

@end

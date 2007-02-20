//
//  TriviaWindowController.h
//  TriviaPlayer
//
//  Created by Nur Monson on 11/3/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FullscreenSheetController.h"
#import "TriviaOutlineViewController.h"
#import "TriviaGameController.h"

@protocol gameController
- (BOOL)startGame;
- (BOOL)pauseGame;
- (BOOL)stopGame;
- (BOOL)backward;
- (BOOL)forward;

// for game setup
- (NSView *)hostView;
- (NSView *)gameView;
- (unsigned)maxPlayers;
@end

@protocol gameControllerDelegate
- (void)startTurnTimer;
- (void)stopTurnTimer;
- (void)resetTurnTimer;

- (void)endGame;

- (NSArray *)getPlayers;
@end

// don't forget to manage fullscreen outlets and actions
// see NSToolbar's -items method
@interface TriviaWindowController : NSObject {
	IBOutlet NSWindow *controlWindow;
	IBOutlet NSWindow *gameWindow;
	IBOutlet NSMenuItem *fullscreenMenuItem;
	IBOutlet TriviaOutlineViewController *questionController;
	IBOutlet TriviaGameController *gameController;
	NSToolbarItem *playToolbarItem;
	
	
	FullscreenSheetController *fullscreenController;
}

- (IBAction)toggleFullscreen:(id)sender;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)stop:(id)sender;

@end

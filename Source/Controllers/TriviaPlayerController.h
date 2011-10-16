//
//  TriviaPlayerController.h
//  TriviaPlayer
//
//  Created by Nur Monson on 9/25/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaPlayer.h"
#import "../WindowControllers/TriviaPlayerGetInputController.h"


@interface TriviaPlayerController : NSObject<TIPInputManagerDelegate> {
	NSMutableArray *players;
	IBOutlet NSArrayController *playerArrayController;
	NSArray *sortDescriptors;
	id _delegate;
	
	TriviaPlayerGetInputController *_getInputWindow;
}

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (NSMutableArray *)players;
- (void)setPlayers:(NSArray *)newPlayers;
- (NSArray *)sortDescriptors;

- (IBAction)addPlayer:(id)sender;
- (IBAction)removePlayer:(id)sender;

- (BOOL)allDisabled;
- (void)disableAllPlayers;
- (void)enableAllPlayers;

- (IBAction)registerInput:(id)sender;
@end

@interface NSObject (PlayerDelegate)
- (void)playerBuzzed:(TriviaPlayer *)thePlayer;
@end

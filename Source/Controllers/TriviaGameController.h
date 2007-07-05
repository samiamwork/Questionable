//
//  TriviaGameController.h
//  TriviaPlayer
//
//  Created by Nur Monson on 10/2/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import <TIPScreenSelectionViewFramework/TIPScreenSelectionView.h>
#import "TriviaTimer.h"
#import "TriviaBoard.h"
#import "TriviaBoardOpenGLView.h"
#import "TriviaBoardSimpleView.h"
#import "TIPGameTimerView.h"
#import "TriviaPlayerController.h"
#import "TriviaOutlineViewController.h"


@interface TriviaGameController : NSObject {
	IBOutlet TriviaBoardOpenGLView *mainBoardView;
	IBOutlet TriviaBoardSimpleView *simpleBoardView;
	IBOutlet TriviaOutlineViewController *questionController;
	IBOutlet TriviaPlayerController *playerController;
	
	IBOutlet TIPGameTimerView *roundTimerProgress;
	
	IBOutlet NSButton *correctButton;
	IBOutlet NSButton *incorrectButton;
	
	IBOutlet NSTextField *nameField;
	
	TriviaTimer *roundTimer;
	TriviaTimer *questionTimer;
	NSTimeInterval roundTimeLength;
	NSTimeInterval questionTimeLength;
	
	TriviaTimer *displayTimer;
	NSTimeInterval displayTimeLength;
	
	BOOL paused;
	
	unsigned selectedQuestionIndex;
	unsigned selectedCategoryIndex;
	TriviaQuestion *selectedQuestion;
	TriviaBoard *currentBoard;
	TriviaPlayer *buzzedPlayer;
	
	id delegate;
}

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (void)questionSelected:(unsigned)questionIndex inCategory:(unsigned)categoryIndex;
- (BOOL)startRound;
- (void)pauseRound;
- (void)stopRound;
- (void)skipForward;
- (void)skipForward;

- (IBAction)correctAnswer:(id)sender;
- (IBAction)incorrectAnswer:(id)sender;

@end

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
#import "TriviaBoardView.h"
#import "TriviaBoardSimpleView.h"
#import "TIPGameTimerView.h"
#import "TriviaPlayerController.h"
#import "TriviaOutlineViewController.h"


@interface TriviaGameController : NSObject {
	IBOutlet TriviaBoardView *mainBoardView;
	IBOutlet TriviaBoardSimpleView *simpleBoardView;
	IBOutlet TriviaOutlineViewController *questionController;
	IBOutlet TriviaPlayerController *playerController;
	//IBOutlet NSTextView *questionView;
	IBOutlet NSTextView *answerView;
	IBOutlet NSTextField *buzzedPlayerName;
	
	IBOutlet TIPGameTimerView *roundTimerProgress;
	IBOutlet TIPGameTimerView *questionTimerProgress;
	
	TriviaTimer *roundTimer;
	TriviaTimer *questionTimer;
	NSTimeInterval roundTimeLength;
	NSTimeInterval questionTimeLength;
	
	NSTimer *displayTimer;
	NSTimeInterval displayTimeLength;
	
	BOOL paused;
	
	unsigned selectedQuestionIndex;
	unsigned selectedCategoryIndex;
	TriviaQuestion *selectedQuestion;
	TriviaBoard *currentBoard;
	TriviaPlayer *buzzedPlayer;
	
}

- (void)questionSelected:(unsigned)questionIndex inCategory:(unsigned)categoryIndex;
- (BOOL)startRound;
- (void)pauseRound;
- (void)stopRound;
- (void)skipForward;
- (void)skipForward;

- (IBAction)correctAnswer:(id)sender;
- (IBAction)incorrectAnswer:(id)sender;

@end

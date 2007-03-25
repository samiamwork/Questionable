//
//  TriviaGameController.m
//  TriviaPlayer
//
//  Created by Nur Monson on 10/2/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaGameController.h"
#import "TriviaSoundController.h"


@implementation TriviaGameController

- (id)init
{
	if( (self = [super init]) ) {
		displayTimer = nil;
		currentBoard = nil;
		paused = NO;
				
		// all times in seconds
		roundTimeLength = 28.0*60.0;
		questionTimeLength = 15.0;
		displayTimeLength = 5.0f;
		
		roundTimer = [[TriviaTimer timerWithLength:roundTimeLength interval:1.0 target:self selector:@selector(roundTimerFired)] retain];
		questionTimer = [[TriviaTimer timerWithLength:questionTimeLength interval:0.1 target:self selector:@selector(questionTimerFired)] retain];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerBuzzed:) name:@"TIPTriviaPlayerBuzzed" object:nil];
	}
	
	return self;
}

//TODO: fill this out
- (void)dealloc
{
	[roundTimer release];
	[questionTimer release];
	[super dealloc];
}

- (void)awakeFromNib
{
	[simpleBoardView setDelegate:self];
	
	[incorrectButton setEnabled:NO];
	[correctButton setEnabled:NO];
}
#pragma mark question methods

- (void)showQuestion
{
	[mainBoardView setQuestion:selectedQuestion];
	[mainBoardView showQuestion];
	
	[simpleBoardView setQuestion:selectedQuestion];
	[simpleBoardView showQuestion];
	[simpleBoardView setTimerLevel:4];
}

- (void)showAnswer
{	
	[questionTimer stop];
	
	[playerController disableAllPlayers];
	
	[selectedQuestion setUsed:YES];
	
	[mainBoardView showAnswer];
	[simpleBoardView showAnswer];
	[simpleBoardView setTimerLevel:0];
	
	buzzedPlayer = nil;
	selectedQuestion = nil;
	
	displayTimer = [NSTimer scheduledTimerWithTimeInterval:displayTimeLength target:self selector:@selector(answerTimerFired:) userInfo:nil repeats:NO];
}

- (void)questionSelected:(unsigned)questionIndex inCategory:(unsigned)categoryIndex
{
	// don't select a new question if we're already answering one
	if( ![questionTimer stopped] )
		return;
	
	selectedCategoryIndex = categoryIndex;
	selectedQuestionIndex = questionIndex;
	selectedQuestion = [currentBoard getQuestion:selectedQuestionIndex inCategory:selectedCategoryIndex];
	
	[self showQuestion];

	[questionTimer start];
	
	[playerController enableAllPlayers];
}

- (IBAction)correctAnswer:(id)sender
{
	if( buzzedPlayer == nil )
		return;
	if( selectedQuestion == nil )
		return;
	
	[[TriviaSoundController defaultController] playSound:SoundThemeSoundCorrectAnswer];
	
	[buzzedPlayer addPoints:(selectedQuestionIndex+1) * 100];
	[self showAnswer];
}
- (IBAction)incorrectAnswer:(id)sender
{
	if( buzzedPlayer == nil )
		return;
	if( selectedQuestion == nil)
		return;
	
	[buzzedPlayer subtractPoints:(selectedQuestionIndex+1) * 100];
	buzzedPlayer = nil;
	
	[[TriviaSoundController defaultController] playSound:SoundThemeSoundIncorrectAnswer];
	
	if( [playerController allDisabled] )
		[self showAnswer];
	else {
		//[mainBoardView removeBadgeWithRedraw:YES];

		[questionTimer start];
	}
}

- (void)playerBuzzed:(NSNotification *)theNotification
{
	if( paused )
		return;
	if( buzzedPlayer != nil )
		return;
	
	buzzedPlayer = [theNotification object];
	if( ![buzzedPlayer enabled] )
		return;
	// would be better if I could disable all players and then reenable
	// them after this player is done, but then I'd have to also re-disable
	// the players who might have been disabled before when they answered this
	// same question wrong
	[buzzedPlayer setEnabled:NO];
	
	[[TriviaSoundController defaultController] playSound:SoundThemeSoundBuzzIn];
	
	//[mainBoardView addBadgeWithString:[buzzedPlayer name]];

	[incorrectButton setEnabled:YES];
	[correctButton setEnabled:YES];
	
	[questionTimer start];
}

#pragma mark Game Methods

- (BOOL)startRound
{
	/*
	// can't start a game without at least two players
	if( [[playerController players] count] == 0 ) {
		printf("not enough players (%d)! Not starting game!\n", [[playerController players] count]);
		return NO;
	}
	 */

	// if we're running then pause/unpause
	if( ![roundTimer stopped] ) {
		[self pauseRound];
		return YES;
	}

	[roundTimerProgress setMaxTime:roundTimeLength];
	[roundTimerProgress setCurrentTime:0.0];
	[roundTimerProgress setStopped:NO];
	
	[roundTimer start];
	
	currentBoard = [questionController checkoutBoard];
	[simpleBoardView setBoard:currentBoard];
	[mainBoardView setBoard:currentBoard];
	
	[mainBoardView setPlayers:[playerController players]];
	
	[mainBoardView showBoard];
	[simpleBoardView showBoard];
	
	return YES;
}

- (void)pauseRound
{
	if( [roundTimer stopped] )
		return;
	
	[roundTimer pause];
	[questionTimer pause];
}
- (void)skipForward
{
}
- (void)skipBackward
{
	// this is harder because we have to undo anything that was done before
	// could do this with our own NSUndoManager instance just for game history
}

- (void)stopRound
{
	[roundTimer stop];
	
	if( displayTimer != nil) {
		[displayTimer invalidate];
		displayTimer = nil;
	}
	
	[questionController checkinBoard];
	currentBoard = nil;
	[simpleBoardView setBoard:nil];
	
	[mainBoardView setBoard:nil];
	[mainBoardView showPlaceholder];
	
	// reset question timer if it's running.
	[questionTimer stop];
	[roundTimerProgress setStopped:YES];
}

#pragma mark game timers

- (void)roundTimerFired
{
	[roundTimerProgress setCurrentTime:[roundTimer timeElapsed]];
	
	if( [roundTimer stopped] )
		[self stopRound];
}

- (void)questionTimerFired
{
	if( [questionTimer stopped] ) {
		
		if( buzzedPlayer != nil )
			[self incorrectAnswer:nil];
		else {
			[[TriviaSoundController defaultController] playSound:SoundThemeSoundIncorrectAnswer];
			[playerController disableAllPlayers];
			[self showAnswer];
		}
		
		[incorrectButton setEnabled:NO];
		[correctButton setEnabled:NO];
	} else
		[simpleBoardView setTimerLevel:[questionTimer currentLevel]];
	
}

// fires only once because we need no indicator for progress
- (void)answerTimerFired:(NSTimer *)theTimer
{
	[mainBoardView showPlayers];
	displayTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(playerStatTimerFired:) userInfo:nil repeats:NO];
}

- (void)playerStatTimerFired:(NSTimer *)theTimer
{
	displayTimer = nil;
	if( [currentBoard allUsed] )
		[self stopRound];
	else {
		[mainBoardView showBoard];
		[simpleBoardView showBoard];
	}
}
@end

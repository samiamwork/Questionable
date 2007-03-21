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
}
#pragma mark question methods

- (void)showQuestion
{
	//[questionView setString:[selectedQuestion question]];
	[answerView setString:[selectedQuestion answer]];
	[buzzedPlayerName setStringValue:@""];
	
	[mainBoardView setQuestion:selectedQuestion];
	[mainBoardView showQuestion];
	
	[simpleBoardView setQuestion:selectedQuestion];
	[simpleBoardView showQuestion];
}

- (void)showAnswer
{	
	[questionTimer stop];
	[questionTimerProgress setStopped:YES];
	
	[playerController disableAllPlayers];
	
	[selectedQuestion setUsed:YES];
	
	//[mainBoardView removeBadgeWithRedraw:NO];
	[mainBoardView showAnswer];
	[simpleBoardView showAnswer];
	
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
	[questionTimerProgress setMaxTime:questionTimeLength];
	[questionTimerProgress setCurrentTime:0.0];
	[questionTimerProgress setStopped:NO];
	
	[playerController enableAllPlayers];
}

- (IBAction)correctAnswer:(id)sender
{
	if( buzzedPlayer == nil )
		return;
	if( selectedQuestion == nil )
		return;
	
	[[TriviaSoundController defaultController] playSound:SoundThemeSoundCorrectAnswer];
	
	//[buzzedPlayer addPoints:[selectedQuestion points]];
	[buzzedPlayer addPoints:(selectedQuestionIndex+1) * 100];
	[buzzedPlayerName setStringValue:@""];
	[self showAnswer];
}
- (IBAction)incorrectAnswer:(id)sender
{
	if( buzzedPlayer == nil )
		return;
	if( selectedQuestion == nil)
		return;
	
	//[buzzedPlayer subtractPoints:[selectedQuestion points]];
	[buzzedPlayer subtractPoints:(selectedQuestionIndex+1) * 100];
	[buzzedPlayerName setStringValue:@""];
	buzzedPlayer = nil;
	
	[[TriviaSoundController defaultController] playSound:SoundThemeSoundIncorrectAnswer];
	
	if( [playerController allDisabled] )
		[self showAnswer];
	else {
		//[mainBoardView removeBadgeWithRedraw:YES];

		[questionTimer start];
		[questionTimerProgress setMaxTime:questionTimeLength];
		[questionTimerProgress setCurrentTime:0.0];
		[questionTimerProgress setStopped:NO];
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
	
	[buzzedPlayerName setStringValue:[buzzedPlayer name]];
	
	[[TriviaSoundController defaultController] playSound:SoundThemeSoundBuzzIn];
	
	//[mainBoardView addBadgeWithString:[buzzedPlayer name]];

	[questionTimer start];
	[questionTimerProgress setMaxTime:questionTimeLength];
	[questionTimerProgress setCurrentTime:0.0];
	[questionTimerProgress setStopped:NO];
}

#pragma mark Game Methods

- (BOOL)startRound
{
	// can't start a game without at least two players
	if( [[playerController players] count] == 0 ) {
		printf("not enough players (%d)! Not starting game!\n", [[playerController players] count]);
		return NO;
	}

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
	[questionTimerProgress setStopped:YES];
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
	[questionTimerProgress setCurrentTime:[questionTimer timeElapsed]];

	if( [questionTimer stopped] ) {
		
		if( buzzedPlayer != nil )
			[self incorrectAnswer:nil];
		else {
			[[TriviaSoundController defaultController] playSound:SoundThemeSoundIncorrectAnswer];
			[playerController disableAllPlayers];
			[self showAnswer];
		}
		
	}
	
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

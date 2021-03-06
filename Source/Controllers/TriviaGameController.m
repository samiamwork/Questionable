//
//  TriviaGameController.m
//  TriviaPlayer
//
//  Created by Nur Monson on 10/2/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaGameController.h"
#import "TriviaSoundController.h"

@interface NSObject (TriviaGameControllerDelegate)
- (void)willStopGame:(TriviaGameController *)aGameController;
- (void)willPauseGame:(TriviaGameController *)aGameController;
@end

@implementation TriviaGameController

- (id)init
{
	if( (self = [super init]) ) {
		displayTimer = nil;
		currentBoard = nil;
		paused = NO;
				
		// all times in seconds
		displayTimeLength = 5.0f;
		NSDictionary *defaults = [[NSUserDefaultsController sharedUserDefaultsController] values];
		roundTimeLength = [[defaults valueForKey:@"lengthOfGame"] doubleValue]*60.0;
		questionTimeLength = [[defaults valueForKey:@"lengthOfQuestion"] doubleValue];
		
		roundTimer = [[TriviaTimer timerWithLength:roundTimeLength interval:1.0 target:self selector:@selector(roundTimerFired)] retain];
		questionTimer = [[TriviaTimer timerWithLength:questionTimeLength interval:0.1 target:self selector:@selector(questionTimerFired)] retain];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerBuzzed:) name:@"TIPTriviaPlayerBuzzed" object:nil];
	}
	
	return self;
}

//TODO: fill this out
- (void)dealloc
{
	[roundTimer stop];
	[roundTimer release];
	[questionTimer stop];
	[questionTimer release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	[playerController setDelegate:self];
	[simpleBoardView setDelegate:self];
	
	[incorrectButton setEnabled:NO];
	[correctButton setEnabled:NO];
}

- (id)delegate
{
	return delegate;
}
- (void)setDelegate:(id)newDelegate
{
	delegate = newDelegate;
}

#pragma mark question methods

- (void)showQuestion
{
	[mainBoardView setQuestion:selectedQuestion];
	[mainBoardView showQuestion];
	
	[simpleBoardView setQuestion:selectedQuestion];
	[simpleBoardView showQuestion];
}

- (void)showAnswer
{	
	[questionTimer stop];
	
	[playerController disableAllPlayers];
	
	[selectedQuestion setUsed:YES];
	
	[mainBoardView showAnswer];
	[simpleBoardView showAnswer];
	[simpleBoardView stopTimer];
	
	buzzedPlayer = nil;
	selectedQuestion = nil;
	
	//displayTimer = [NSTimer scheduledTimerWithTimeInterval:displayTimeLength target:self selector:@selector(answerTimerFired:) userInfo:nil repeats:NO];
	//displayTimer = [[TriviaTimer timerWithLength:displayTimeLength interval:displayTimeLength target:self selector:@selector(answerTimerFired)] retain];
	displayTimer = [[TriviaTimer alloc] init];
	[displayTimer setTimeLength:displayTimeLength];
	[displayTimer setTimeInterval:displayTimeLength];
	[displayTimer setTarget:self selector:@selector(answerTimerFired)];
	[displayTimer start];
}

- (void)triviaBoardViewTransitionDone:(TriviaBoardOpenGLView *)aView
{
	NSDictionary *defaults = [[NSUserDefaultsController sharedUserDefaultsController] values];
	questionTimeLength = [[defaults valueForKey:@"lengthOfQuestion"] doubleValue];
	[questionTimer release];
	questionTimer = [[TriviaTimer timerWithLength:questionTimeLength interval:0.1 target:self selector:@selector(questionTimerFired)] retain];
	[questionTimer start];
	[simpleBoardView startTimerOfLength:questionTimeLength];
	
	[playerController enableAllPlayers];
	//[mainBoardView setTransitionDoneCallback:nil];
	[mainBoardView setDelegate:nil];
}

- (void)questionSelected:(unsigned)questionIndex inCategory:(unsigned)categoryIndex
{
	// don't select a new question if we're already answering one
	if( ![questionTimer stopped] )
		return;
	
	selectedCategoryIndex = categoryIndex;
	selectedQuestionIndex = questionIndex;
	selectedQuestion = [currentBoard getQuestion:selectedQuestionIndex inCategory:selectedCategoryIndex];
	
	/*
	NSInvocation *doneCallback = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(questionReady)]];
	[doneCallback setSelector:@selector(questionReady)];
	[doneCallback setTarget:self];
	 */
	//[mainBoardView setTransitionDoneCallback:doneCallback];
	[mainBoardView setDelegate:self];
	[self showQuestion];
}

- (IBAction)correctAnswer:(id)sender
{
	if( buzzedPlayer == nil )
		return;
	if( selectedQuestion == nil )
		return;
	
	if( [roundTimer paused] )
		[self pauseRound];
	
	[[TriviaSoundController defaultController] playSound:SoundThemeSoundCorrectAnswer];
	
	[buzzedPlayer addPoints:(selectedQuestionIndex+1) * 100];
	[nameField setToolTip:[NSString stringWithFormat:NSLocalizedString(@"last correct answer by \"%@\"",@"last correct answer by \"%@\""), [buzzedPlayer name]]];

	[self showAnswer];

	[nameField setStringValue:@""];
	
	[incorrectButton setEnabled:NO];
	[correctButton setEnabled:NO];
}
- (IBAction)incorrectAnswer:(id)sender
{
	if( buzzedPlayer == nil )
		return;
	if( selectedQuestion == nil)
		return;
	
	if( [roundTimer paused] )
		[self pauseRound];
	
	[buzzedPlayer subtractPoints:(selectedQuestionIndex+1) * 100];
	buzzedPlayer = nil;
	
	[[TriviaSoundController defaultController] playSound:SoundThemeSoundIncorrectAnswer];
	
	if( [playerController allDisabled] )
		[self showAnswer];
	else {
		[simpleBoardView showQuestion];
		[questionTimer setTimeLength:questionTimeLength/2.0];
		[questionTimer start];
		[simpleBoardView startTimerOfLength:questionTimeLength/2.0];
	}
	
	[nameField setStringValue:@""];
	
	[incorrectButton setEnabled:NO];
	[correctButton setEnabled:NO];
}

- (void)playerBuzzed:(TriviaPlayer *)thePlayer
{
	if( [roundTimer stopped] || [roundTimer paused] || [questionTimer paused] )
		return;
	if( buzzedPlayer != nil )
		return;
	
	buzzedPlayer = thePlayer;
	if( ![buzzedPlayer enabled] )
		return;
	// would be better if I could disable all players and then reenable
	// them after this player is done, but then I'd have to also re-disable
	// the players who might have been disabled before when they answered this
	// same question wrong
	[buzzedPlayer setEnabled:NO];
	
	[[TriviaSoundController defaultController] playSound:SoundThemeSoundBuzzIn];
	
	[nameField setStringValue:[buzzedPlayer name]];
	[simpleBoardView showAnswer];

	[incorrectButton setEnabled:YES];
	[correctButton setEnabled:YES];
	
	[questionTimer setTimeLength:questionTimeLength];
	[questionTimer start];
	[simpleBoardView startTimerOfLength:questionTimeLength];
}

#pragma mark Game Methods

- (BOOL)startRound
{
	// if we're running then pause/unpause
	if( ![roundTimer stopped] ) {
		if( [roundTimer paused] )
			[mainBoardView refresh];
		[self pauseRound];
		return YES;
	}

	[[TriviaSoundController defaultController] playSound:SoundThemeSoundGameStart];
	NSDictionary *defaults = [[NSUserDefaultsController sharedUserDefaultsController] values];
	roundTimeLength = [[defaults valueForKey:@"lengthOfGame"] doubleValue]*60.0;
	[roundTimer stop];
	[roundTimer release];
	roundTimer = [[TriviaTimer timerWithLength:roundTimeLength interval:1.0 target:self selector:@selector(roundTimerFired)] retain];
	
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
	[simpleBoardView pauseTimer];
	[mainBoardView pause];
	[displayTimer pause];
	
	if( delegate != nil && [delegate respondsToSelector:@selector(willPauseGame:)] )
		[delegate willPauseGame:self];
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
	[[TriviaSoundController defaultController] playSound:SoundThemeSoundGameEnd];
	
	if( displayTimer != nil) {
		[displayTimer stop];
		[displayTimer release];
		displayTimer = nil;
	}
	
	[questionController checkinBoard];
	[currentBoard setUnused];
	currentBoard = nil;
	[simpleBoardView setBoard:nil];
	
	[mainBoardView setBoard:nil];
	[mainBoardView showPlaceholder];
	
	// reset question timer if it's running.
	[questionTimer stop];
	[roundTimerProgress setStopped:YES];
	if( buzzedPlayer != nil ) {
		[buzzedPlayer setEnabled:YES];
		buzzedPlayer = nil;
	}

	[nameField setToolTip:nil];
	if( delegate != nil && [delegate respondsToSelector:@selector(willStopGame:)] )
		[delegate willStopGame:self];
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
	[mainBoardView setProgress:1.0f-(float)[questionTimer timeElapsed]/(float)[questionTimer timeLength]];
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
	}

}

// fires only once because we need no indicator for progress
- (void)answerTimerFired
{
	[mainBoardView showPlayers];
	//displayTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(playerStatTimerFired:) userInfo:nil repeats:NO];
	[displayTimer stop];
	[displayTimer release];
	//displayTimer = [[TriviaTimer timerWithLength:5.0 interval:5.0 target:self selector:@selector(playerStatTimerFired)] retain];
	displayTimer = [[TriviaTimer alloc] init];

	[displayTimer setTimeLength:5.0];
	[displayTimer setTimeInterval:5.0];
	[displayTimer setTarget:self selector:@selector(playerStatTimerFired)];
	
	[displayTimer start];
}

- (void)playerStatTimerFired
{
	[displayTimer stop];
	[displayTimer release];
	displayTimer = nil;

	if( [currentBoard allUsed] )
		[self stopRound];
	else {
		[mainBoardView showBoard];
		[simpleBoardView showBoard];
	}
}
@end

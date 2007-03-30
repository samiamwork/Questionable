//
//  TriviaBoardSimpleView.h
//  TriviaPlayer
//
//  Created by Nur Monson on 10/19/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaBoard.h"
#import "TIPTextContainer.h"
#import "TIPCGUtils.h"

typedef enum TriviaSimpleViewState {
	kTriviaSimpleViewNothing,
	kTriviaSimpleViewBoard,
	kTriviaSimpleViewQuestion,
	kTriviaSimpleViewAnswer
} TriviaSimpleViewState;

@interface TriviaBoardSimpleView : NSView {
	TriviaBoard *mainBoard;
	TriviaQuestion *_question;
	NSString *_playerName;
	unsigned questionsPerCategory;
	
	IBOutlet id delegate;
	
	TIPTextContainer *placeholderMessage;
	NSMutableArray *titleArray;
	NSMutableArray *pointArray;
	
	TriviaSimpleViewState _viewState;
	unsigned int _timerLevel;
}

- (void)setDelegate:(id)newDelegate;
- (id)delegate;
- (void)setBoard:(TriviaBoard *)newBoard;
- (TriviaBoard *)board;
- (void)setQuestion:(TriviaQuestion *)newQuestion;
- (TriviaQuestion *)question;
- (void)setPlayerName:(NSString *)aPlayerName;
- (NSString *)playerName;
- (void)setTimerLevel:(unsigned int)newLevel;
- (unsigned int)timerLevel;

- (void)showBoard;
- (void)showQuestion;
- (void)showAnswer;
@end

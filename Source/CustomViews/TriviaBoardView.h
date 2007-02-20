//
//  TriviaBoardView.h
//  TriviaPlayer
//
//  Created by Nur Monson on 10/5/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaBoard.h"
#import "TriviaDrawablePlaceholder.h"
#import "TriviaDrawableGameBoard.h"
#import "TriviaDrawablePlayerStatus.h"
#import "TriviaDrawableQA.h"
#import "TriviaDrawableBadge.h"

#import "TIPFullViewTransition.h"

typedef enum _TIPTriviaBoardViewState {
	kTIPTriviaBoardViewStatePlaceholder,
	kTIPTriviaBoardViewStateBoard,
	kTIPTriviaBoardViewStateQuestion,
	kTIPTriviaBoardViewStateAnswer,
	kTIPTriviaBoardViewStatePlayers
} TIPTriviaBoardViewState;

@interface TriviaBoardView : NSView {
	CGContextRef currentContext;
	CGAffineTransform boardTransform;
	NSSize lastSize;
	float scale;
	NSPoint translate;
	
	TriviaBoard *mainBoard;
	int numberOfCategories;
	int questionsPerCategory;

	TriviaDrawablePlaceholder *placeholderDrawable;
	TriviaDrawableGameBoard *gameBoardDrawable;
	TriviaDrawablePlayerStatus *playerStatusDrawable;
	TriviaDrawableQA *questionDrawable;
	TriviaDrawableQA *answerDrawable;
	
	TriviaDrawable *currentDrawable;
	
	TriviaDrawableBadge *badgeDrawable;
	BOOL drawBadge;
	
	TIPTriviaBoardViewState theViewState;
	TIPTriviaBoardViewState lastViewState;
	BOOL stateTransition;

	TIPFullViewTransition *boardTransitionFilter;
}

- (void)setBoard:(TriviaBoard *)newBoard;
- (TriviaBoard *)board;
- (void)setPlayers:(NSArray *)newPlayers;
//- (NSArray *)players;

- (void)showBoard;
- (void)showPlayers;
- (void)showPlaceholder;
- (void)showQuestion:(TriviaQuestion *)aQuestion;
- (void)showAnswerToQuestion:(TriviaQuestion *)aQuestion;

- (void)addBadgeWithString:(NSString *)aString;
- (void)removeBadgeWithRedraw:(BOOL)redrawBoard;

- (void)rebuildScale;
- (void)enable:(BOOL)enable question:(unsigned)theQuestionIndex inCategory:(unsigned)theCategoryIndex;

- (void)setBoardViewState:(TIPTriviaBoardViewState)newState;
@end

//
//  TriviaBoardOpenGLView.h
//  Questionable
//
//  Created by Nur Monson on 2/20/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TriviaBoard.h"
#import "RectangularBox.h"

typedef enum TIPTriviaBoardViewState {
	kTIPTriviaBoardViewStatePlaceholder,
	kTIPTriviaBoardViewStateBoard,
	kTIPTriviaBoardViewStateQuestion,
	kTIPTriviaBoardViewStateAnswer,
	kTIPTriviaBoardViewStatePlayers
} TIPTriviaBoardViewState;

@interface TriviaBoardOpenGLView : NSView {
	NSOpenGLContext *_windowedContext;
	NSOpenGLPixelFormat *_windowedPixelFormat;
	
	float _targetAspectRatio;
	BOOL _preserveTargetAspectRatio;
	BOOL _needsReshape;
	BOOL _isFirstFrame;
	
	NSSize _targetSize;
	NSSize _contextSize;
	
	//Trivia Objects
	TriviaBoard *_mainBoard;
	TriviaQuestion *_question;
	NSArray *_players;
	
	TIPTriviaBoardViewState theViewState;
	TIPTriviaBoardViewState lastViewState;
	NSAnimation *_transitionAnimation;
	NSTimer *_transitionTimer;
	
	//display Objects
	RectangularBox *_categoryTitleBox;
	RectangularBox *_pointsBox;
	NSMutableArray *_categoryTitleStrings;
	NSMutableArray *_questionPointStrings;
	
	//display metrics
	NSSize _questionTitleSize;
	NSSize _questionPointSize;
	NSSize _boardPaddingSize;
	NSSize _boardMarginSize;
	NSSize _titleStringSize;
	NSSize _pointStringSize;
}

- (void)setBoard:(TriviaBoard *)newBoard;
- (TriviaBoard *)board;
- (void)setPlayers:(NSArray *)newPlayers;
- (NSArray *)players;
- (void)setQuestion:(TriviaQuestion *)newQuestion;
- (TriviaQuestion *)question;

- (void)showBoard;
- (void)showPlayers;
- (void)showPlaceholder;
- (void)showQuestion;
- (void)showAnswer;

- (void)setBoardViewState:(TIPTriviaBoardViewState)newState;
@end

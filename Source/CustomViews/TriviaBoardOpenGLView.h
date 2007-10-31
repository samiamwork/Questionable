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
#import "TriviaPlayer.h"
#import "RectangularBox.h"
#import "TransitionAnimation.h"
#import "../Helpers/ArcTimer.h"
#import "TriviaSceneBoard.h"
#import "TriviaScenePlaceholder.h"
#import "TriviaSceneQA.h"
#import "TriviaScenePlayers.h"

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
	NSPoint _adjustedOrigin;
	float _scale;
	
	//Trivia Objects
	TriviaBoard *_mainBoard;
	// this is needed because our working array will be different
	// than the one passed if the program is unregistered.
	NSArray *_categories;
	TriviaQuestion *_question;
	NSArray *_players;
	
	TIPTriviaBoardViewState theViewState;
	TIPTriviaBoardViewState lastViewState;
	TransitionAnimation *_transitionAnimation;
	
	//display Objects	
	TriviaScenePlaceholder *_placeholderScene;
	TriviaSceneBoard *_boardScene;
	TriviaSceneQA *_questionScene;
	TriviaSceneQA *_answerScene;
	TriviaScenePlayers *_playersScene;
	
	//NSInvocation *_transitionDoneCallback;
	id _delegate;
}

- (void)setBoard:(TriviaBoard *)newBoard;
- (TriviaBoard *)board;
- (void)setPlayers:(NSArray *)newPlayers;
- (NSArray *)players;
- (void)setQuestion:(TriviaQuestion *)newQuestion;
- (TriviaQuestion *)question;

- (void)setProgress:(float)newProgress;
//- (void)setTransitionDoneCallback:(NSInvocation *)callback;
- (void)setDelegate:(id)theDelegate;

- (void)showBoard;
- (void)showPlayers;
- (void)showPlaceholder;
- (void)showQuestion;
- (void)showAnswer;

- (void)setBoardViewState:(TIPTriviaBoardViewState)newState;
- (void)refresh;

- (void)pause;
@end

//
//  TriviaBoardView.m
//  TriviaPlayer
//
//  Created by Nur Monson on 10/5/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaBoardView.h"
//#import "CTGradient.h"
#include "TIPCGUtils.h"

#define BASEWIDTH 640.0f
#define BASEHEIGHT 480.0f

@implementation TriviaBoardView

- (id)initWithFrame:(NSRect)frameRect
{
	if( (self = [super initWithFrame:frameRect]) ) {
	
		boardTransform = CGAffineTransformMake(1.0f,0.0f,0.0f,1.0f,0.0f,0.0f);
		lastSize = frameRect.size;
	
		[self rebuildScale];
	
		currentContext = NULL;
		mainBoard = nil;
		//players = nil;
	
		placeholderDrawable = [[TriviaDrawablePlaceholder alloc] init];
		gameBoardDrawable = [[TriviaDrawableGameBoard alloc] init];
		playerStatusDrawable = [[TriviaDrawablePlayerStatus alloc] init];
		questionDrawable = [[TriviaDrawableQA alloc] init];
		[questionDrawable setTitle:@"Question"];
		answerDrawable = [[TriviaDrawableQA alloc] init];
		[answerDrawable setTitle:@"Answer"];
		badgeDrawable = [[TriviaDrawableBadge alloc] init];
		
		lastViewState = theViewState = kTIPTriviaBoardViewStatePlaceholder;
		currentDrawable = placeholderDrawable;
		stateTransition = NO;
		
		boardTransitionFilter = [[TIPFullViewTransition alloc] init];
		[boardTransitionFilter setOwnerView:self];
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	if( mainBoard != nil )
		[mainBoard release];

	[placeholderDrawable release];
	[gameBoardDrawable release];
	[playerStatusDrawable release];
	[questionDrawable release];
	[answerDrawable release];
}

#pragma mark Set and Get

- (void)setBoard:(TriviaBoard *)newBoard
{
	if( newBoard == mainBoard )
		return;
	
	[mainBoard release];
	mainBoard = newBoard;
	[mainBoard retain];
	
	[gameBoardDrawable setBoard:mainBoard];
	[self setNeedsDisplay:YES];
}

- (TriviaBoard *)board
{
	return mainBoard;
}

- (void)setPlayers:(NSArray *)newPlayers
{
	[playerStatusDrawable setPlayers:newPlayers];
}
- (NSArray *)players
{
	return [playerStatusDrawable players];
}

#pragma mark Show Methods

- (void)showPlaceholder
{
	[self setBoardViewState:kTIPTriviaBoardViewStatePlaceholder];
}

- (void)showBoard;
{
	if( mainBoard != nil )
		[self setBoardViewState:kTIPTriviaBoardViewStateBoard];
	else
		[self setBoardViewState:kTIPTriviaBoardViewStatePlaceholder];
}

- (void)showPlayers;
{
	[self setBoardViewState:kTIPTriviaBoardViewStatePlayers];
}

- (void)showQuestion:(TriviaQuestion *)aQuestion;
{
	[questionDrawable setText:[aQuestion question]];
	[self setBoardViewState:kTIPTriviaBoardViewStateQuestion];
}

- (void)showAnswerToQuestion:(TriviaQuestion *)aQuestion;
{
	[answerDrawable setText:[aQuestion answer]];
	[self setBoardViewState:kTIPTriviaBoardViewStateAnswer];
}

- (void)addBadgeWithString:(NSString *)aString;
{
	if( aString == nil )
		return;
	
	drawBadge = YES;
	
	[badgeDrawable setText:aString];
	//TODO: should just draw it right over the top without calling display
	[self display];
}
- (void)removeBadgeWithRedraw:(BOOL)redrawBoard
{
	if( !drawBadge )
		return;
	
	drawBadge = NO;
	
	if( redrawBoard )
		[self display];
}

#pragma mark Board Methods

- (void)enable:(BOOL)enable question:(unsigned)theQuestionIndex inCategory:(unsigned)theCategoryIndex
{
	//[gameBoardDrawable enable:enable question:theQuestionIndex inCategory:theCategoryIndex];
	[self display];
}

- (TriviaDrawable *)getDrawableForState:(TIPTriviaBoardViewState)theState
{
	switch( theState ) {
		case kTIPTriviaBoardViewStatePlaceholder:
			return placeholderDrawable;
		case kTIPTriviaBoardViewStateBoard:
			return gameBoardDrawable;
		case kTIPTriviaBoardViewStatePlayers:
			return playerStatusDrawable;
		case kTIPTriviaBoardViewStateQuestion:
			return questionDrawable;
		case kTIPTriviaBoardViewStateAnswer:
			return answerDrawable;
		default:
			return placeholderDrawable;
	}
	
	return placeholderDrawable;
}

- (void)setBoardViewState:(TIPTriviaBoardViewState)newState
{
	if( newState == theViewState )
		return;
	// for transition animations
	theViewState = newState;
	currentDrawable = [self getDrawableForState:theViewState];
	
	// setup transition
	NSRect bounds = [self bounds];
	CGImageRef startImage = [[self getDrawableForState:lastViewState] makeCGImageForSize:bounds.size];
	CGImageRef endImage = [[self getDrawableForState:theViewState] makeCGImageForSize:bounds.size];
	[boardTransitionFilter setStartImage:[CIImage imageWithCGImage:startImage]];
	[boardTransitionFilter setEndImage:[CIImage imageWithCGImage:endImage]];
	
	lastViewState = theViewState;
	stateTransition = YES;
	
	[boardTransitionFilter startTransitionForSeconds:0.5];
	// end transition
	
	// for no transition animations
	//lastViewState = theViewState = newState;
	//stateTransition = NO;
}

#pragma mark rebuilding

- (void)rebuildScale
{
	NSSize newSize = [self frame].size;
	
	if( newSize.width == lastSize.width && newSize.height == lastSize.height )
		return;
	
	boardTransform = CGAffineTransformMake(1.0f,0.0f,0.0f,1.0f,0.0f,0.0f);
	
	float scaleWidth = newSize.width/BASEWIDTH;
	float scaleHeight = newSize.height/BASEHEIGHT;
	
	if( scaleWidth > scaleHeight ) {
		scale = scaleHeight;
		translate.x = (newSize.width - BASEWIDTH*scale)/2.0f;
		translate.y = 0.0f;
	} else {
		scale = scaleWidth;
		translate.x = 0.0f;
		translate.y = (newSize.height - BASEHEIGHT*scale)/2.0f;
	}
	
	boardTransform = CGAffineTransformTranslate(boardTransform, translate.x, translate.y);
	boardTransform = CGAffineTransformScale(boardTransform, scale, scale);
	
	lastSize = newSize;
}

#pragma mark Drawing Methods

- (void)drawRect:(NSRect)rect
{
	NSRect bounds = [self bounds];
	
	currentContext = [[NSGraphicsContext currentContext] graphicsPort];
	[self rebuildScale];

	//CGContextClearRect(currentContext, *(CGRect *)&bounds);
		
	CGContextSaveGState(currentContext);
	
	if( stateTransition ) {
		// draw transition and check if the transition is done
		[boardTransitionFilter drawInRect:*(CGRect *)&bounds];
		
		if( [boardTransitionFilter done] )
			stateTransition = NO;
	} else {
		[currentDrawable drawInRect:NSMakeRect(0.0f,0.0f, lastSize.width, lastSize.height) inContext:currentContext];
		if( drawBadge ) {
			CGContextSaveGState( currentContext );
			CGContextSetShadow( currentContext,CGSizeMake(0.0f, -5.0f),3.0f);
			CGContextBeginTransparencyLayer( currentContext, NULL );
			[badgeDrawable drawInRect:NSMakeRect(lastSize.width*0.6f,lastSize.height*0.8f,lastSize.width*0.3f,lastSize.height*0.1f) inContext:currentContext];
			CGContextEndTransparencyLayer( currentContext );
			CGContextRestoreGState( currentContext );
		}
	}
	
	CGContextRestoreGState(currentContext);
}

#pragma mark NSView Methods

- (void)viewWillStartLiveResize
{
	// make CGLayer for currentDrawable
}

- (void)viewDidEndLiveResize
{
	[self display];
}

@end

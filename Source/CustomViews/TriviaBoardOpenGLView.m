//
//  TriviaBoardOpenGLView.m
//  Questionable
//
//  Created by Nur Monson on 2/20/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TriviaBoardOpenGLView.h"

#define BASE_WIDTH 640.0f
#define BASE_HEIGHT 480.0f
#define BASE_SIZE (NSSize){BASE_WIDTH,BASE_HEIGHT}
#define SCALE_SIZE(a,b) (NSSize){a.width*b,a.height*b}

@implementation TriviaBoardOpenGLView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		
		NSOpenGLPixelFormatAttribute windowedAttributes[] = {
			NSOpenGLPFAWindow,
			NSOpenGLPFAAccelerated,
			NSOpenGLPFADoubleBuffer,
			NSOpenGLPFAColorSize, 24,
			NSOpenGLPFAAlphaSize, 8,
			0 };
		
		_windowedPixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:windowedAttributes];
		_windowedContext = [[NSOpenGLContext alloc] initWithFormat:_windowedPixelFormat shareContext:nil];
		
		if( !_windowedContext ) {
			printf("error creating windowed OpenGL contex\n");
			[self dealloc];
			return nil;
		}
		
		long vsync = 1;
		[_windowedContext setValues:&vsync forParameter:NSOpenGLCPSwapInterval];
		
		_preserveTargetAspectRatio = YES;
		_targetAspectRatio = BASE_WIDTH/BASE_HEIGHT;
		_needsReshape = NO;
		_isFirstFrame = YES;
		
		//Trivia Objects
		_mainBoard = nil;
		_categories = nil;
		_question = nil;
		_players = nil;
		_transitionAnimation = [[TransitionAnimation alloc] initWithDuration:0.5 animationCurve:NSAnimationEaseInOut];
		[_transitionAnimation setAnimationBlockingMode:NSAnimationNonblocking];
		[_transitionAnimation setDelegate:self];
		
		theViewState = lastViewState = kTIPTriviaBoardViewStatePlaceholder;
		
		//Display Objects
		_boardScene = [[TriviaSceneBoard alloc] init];
		_placeholderScene = [[TriviaScenePlaceholder alloc] init];
		_questionScene = nil;
		_answerScene = nil;
		
		_playerNameBox = [[RectangularBox alloc] init];
		[_playerNameBox setSharpCorners:BoxCornerAll];
		[_playerNameBox setLineWidth:1.0f];
		[_playerNameBox setCornerRadius:5.0f];
		_playerPointBox = [[RectangularBox alloc] init];
		[_playerPointBox setSharpCorners:BoxCornerUpperLeft|BoxCornerUpperRight|BoxCornerLowerLeft];
		[_playerPointBox setLineWidth:1.0f];
		[_playerPointBox setCornerRadius:5.0f];
		_playerNameStrings = [[NSMutableArray alloc] init];
		_playerPointStrings = [[NSMutableArray alloc] init];
		
		_transitionDoneCallback = nil;
    }
	
    return self;
}

- (void)dealloc
{
	[_windowedContext release];
	[_windowedPixelFormat release];
	
	[_mainBoard release];
	[_question release];
	[_players release];
	[_transitionAnimation release];
	
	//Display Objects
	[_boardScene release];
	[_placeholderScene release];
	[_questionScene release];
	[_answerScene release];
	
	[_playerNameBox release];
	[_playerPointBox release];
	[_playerNameStrings release];
	[_playerPointStrings release];
	
	[_transitionDoneCallback release];

	[super dealloc];
}

- (NSRect)fitRect:(NSRect)inputRect inRect:(NSRect)inRect
{
	NSRect outputRect;
	outputRect.origin = inRect.origin;
	float rectAspectRatio = inRect.size.width/inRect.size.height;
	float imageAspectRatio = inputRect.size.width/inputRect.size.height;
	
	float zoom;
	if( imageAspectRatio < rectAspectRatio ) {
		zoom = inRect.size.height/inputRect.size.height;
		outputRect.size.height = inRect.size.height;
		outputRect.size.width = roundf( inputRect.size.width*zoom);
		outputRect.origin.x += roundf( (inRect.size.width - outputRect.size.width)/2.0f );
	} else {
		zoom = inRect.size.width/inputRect.size.width;
		outputRect.size.height = roundf( inputRect.size.height*zoom);
		outputRect.size.width = inRect.size.width;
		outputRect.origin.y += roundf( (inRect.size.height - outputRect.size.height)/2.0f );
	}
	
	return outputRect;
}

- (void)regenerateStringTextures
{
	
	if( [_playerNameStrings count] != 0 ) {
		NSEnumerator *stringEnumerator = [_playerNameStrings objectEnumerator];
		StringTexture *aStringTexture;
		while( (aStringTexture = [stringEnumerator nextObject]) ) {
			[aStringTexture setSize:[_playerNameBox size]];
			[aStringTexture setFontSize:ceilf([_playerNameBox size].height*0.8f)];
		}
	}
	if( [_playerPointStrings count] != 0 ) {
		NSEnumerator *stringEnumerator = [_playerPointStrings objectEnumerator];
		StringTexture *aStringTexture;
		while( (aStringTexture = [stringEnumerator nextObject]) ) {
			[aStringTexture setSize:[_playerPointBox size]];
			[aStringTexture setFontSize:ceilf([_playerPointBox size].height*0.7f)];
		}
	}

}

- (void)doReshape
{
	_contextSize = [self bounds].size;
	
	_targetSize = _contextSize;
	
	float targetWidth = _contextSize.height*_targetAspectRatio;
	float targetHeight = _contextSize.width/_targetAspectRatio;
	
	if( targetWidth < _contextSize.width )
		_targetSize.width = targetWidth;
	else if( targetHeight < _contextSize.height )
		_targetSize.height = targetHeight;
	
	[_windowedContext update];
	glViewport(0.0f, 0.0f, _contextSize.width, _contextSize.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	if( !_preserveTargetAspectRatio ) {
		glOrtho(0.0f, _contextSize.width, 0.0f, _contextSize.height, 300.0f, -300.0f);
	} else if( _targetSize.width < _contextSize.width ) {
		float dx = (_contextSize.width - _targetSize.width)/2.0f;
		glOrtho(0.0f-dx, _targetSize.width+dx, 0.0f, _contextSize.height, 300.0f, -300.0f);
	} else if( _targetSize.height < _contextSize.height ) {
		float dy = (_contextSize.height - _targetSize.height)/2.0f;
		glOrtho(0.0f, _contextSize.width, 0.0f-dy, _targetSize.height+dy, 300.0f, -300.0f);
	} else {
		glOrtho(0.0f, _contextSize.width, 0.0f, _contextSize.height, 300.0f, -300.0f);
	}
	
	glMatrixMode(GL_MODELVIEW);
	
	_needsReshape = NO;
	
	[_boardScene setSize:_targetSize];
	[_placeholderScene setSize:_targetSize];
	[_questionScene setSize:_targetSize];
	[_answerScene setSize:_targetSize];
	
	// recalculate display metrics
	_boardPaddingSize = NSMakeSize(15.0f,-2.0f);
	_boardMarginSize = NSMakeSize(10.0f,25.0f);
	
	_playerNameSize = NSMakeSize(_targetSize.width-2.0f*_boardMarginSize.width,ceilf(((_targetSize.height-_boardMarginSize.height*2.0f)/4.0f)*0.5f));
	_playerPointSize = NSMakeSize(_playerNameSize.width,ceilf(((_targetSize.height-_boardMarginSize.height*2.0f)/4.0f)*0.3f));
	_playerPointPadding = ceilf(((_targetSize.height-_boardMarginSize.height*2.0f)/4.0f)*0.2f);
	[_playerNameBox setSize:_playerNameSize];
	[_playerPointBox setSize:_playerPointSize];
	[_playerPointBox setCornerRadius:ceilf(_playerPointSize.height*0.4f)];
		
	[self regenerateStringTextures];
}

- (void)firstFrameSetup
{
	[_windowedContext setView:self];
	[_windowedContext makeCurrentContext];
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_DEPTH_TEST);
	
	_contextSize = NSZeroSize;
	
	_isFirstFrame = NO;
	_needsReshape = YES;
}

- (void)drawPlayerStatus
{
	unsigned int playerIndex;
	for( playerIndex = 0; playerIndex < [_playerNameStrings count] && playerIndex < 4; playerIndex++ ) {
		[_playerNameBox drawWithString:[_playerNameStrings objectAtIndex:playerIndex]];
		glTranslatef(0.0f,-[_playerPointBox size].height,0.0f);
		[_playerPointBox drawWithString:[_playerPointStrings objectAtIndex:playerIndex]];
		glTranslatef(0.0f,-([_playerNameBox size].height+_playerPointPadding),0.0f);
	}
}

- (void)drawState:(TIPTriviaBoardViewState)aState withProgress:(float)progress
{
	glPushMatrix();
	glTranslatef(_contextSize.width*progress,0.0f,0.0f);
	switch( aState ) {
		case kTIPTriviaBoardViewStateBoard:
			[_boardScene draw];
			break;
		case kTIPTriviaBoardViewStateQuestion:
			[_questionScene draw];
			break;
		case kTIPTriviaBoardViewStateAnswer:
			[_answerScene draw];
			break;
		case kTIPTriviaBoardViewStatePlayers:
			glTranslatef(_boardMarginSize.width,_targetSize.height-_boardMarginSize.height-[_playerNameBox size].height,0.0f);
			[self drawPlayerStatus];
			break;
		case kTIPTriviaBoardViewStatePlaceholder:
		default:
			[_placeholderScene draw];
			break;
	}
	glPopMatrix();
}

- (void)drawRect:(NSRect)rect
{
	if( _isFirstFrame )
		[self firstFrameSetup];
	
	NSSize boundSize = [self bounds].size;
	if( _needsReshape || _contextSize.width != boundSize.width || _contextSize.height != boundSize.height )
		[self doReshape];
	
	glClearColor(0.0f,0.0f,0.0f,1.0f);
	glClear( GL_COLOR_BUFFER_BIT );
	
	if( lastViewState != theViewState && ![_transitionAnimation isAnimating] ) {
		switch(lastViewState) {
			case kTIPTriviaBoardViewStateQuestion:
				[_questionScene release];
				_questionScene = nil;
				break;
			case kTIPTriviaBoardViewStateAnswer:
				[_answerScene release];
				_answerScene = nil;
				break;
			case kTIPTriviaBoardViewStatePlayers:
				[_playerNameStrings removeAllObjects];
				[_playerPointStrings removeAllObjects];
				break;
			case kTIPTriviaBoardViewStatePlaceholder:
				break;
			default:
				break;
		}
		
		lastViewState = theViewState;
		[_transitionDoneCallback invoke];
	}
	
	if( theViewState != lastViewState ) {
		float progress = [_transitionAnimation currentValue];
		[self drawState:lastViewState withProgress:progress];
		[self drawState:theViewState withProgress:progress-1.0f];
	} else {
		[self drawState:theViewState withProgress:0.0f];
	}
	
	[_windowedContext flushBuffer];
}

#pragma mark Trivia Methods

- (void)setBoard:(TriviaBoard *)newBoard
{
	if( newBoard == _mainBoard )
		return;
	
	[_mainBoard release];
	_mainBoard = [newBoard retain];
	
	[_categories release];
	NSData *licenseData = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"license"];
	NSData *badData = [NSData data];
	// if unregistered insert the "unregistered" category
	if( APVerifyLicenseData((CFDataRef )badData) ||
		!APVerifyLicenseData((CFDataRef )licenseData) ) {
		TriviaCategory *dummyCategory = [[TriviaCategory alloc] init];
		[dummyCategory setTitle:@"Please Register"];
		_categories = [[_mainBoard categories] arrayByAddingObject:dummyCategory];
		[dummyCategory release];
	} else {
		_categories = [NSArray arrayWithArray:[_mainBoard categories]];
	}
	[_categories retain];
	[_boardScene setCategories:_categories];
	
	[self setNeedsDisplay:YES];
}
- (TriviaBoard *)board
{
	return _mainBoard;
}

- (void)setPlayers:(NSArray *)newPlayers
{
	if( newPlayers == _players )
		return;
	
	[_players release];
	_players = [newPlayers retain];
	[self setNeedsDisplay:YES];
}
- (NSArray *)players
{
	return _players;
}

- (void)setQuestion:(TriviaQuestion *)newQuestion
{
	if( newQuestion == _question )
		return;
	
	[_question release];
	_question = [newQuestion retain];
}
- (TriviaQuestion *)question
{
	return _question;
}

- (void)setProgress:(float)newProgress
{
	if( _questionScene != nil )
		[_questionScene setProgress:newProgress];
	if( theViewState == kTIPTriviaBoardViewStateQuestion )
		[self setNeedsDisplay:YES];
}

- (void)setTransitionDoneCallback:(NSInvocation *)callback
{
	if( callback == _transitionDoneCallback )
		return;
	
	[_transitionDoneCallback release];
	_transitionDoneCallback = [callback retain];
}

- (void)refresh
{
	/*
	if( _questionString != nil )
		[_questionString setString:(NSString *)[_question question]];
	
	if( _answerString != nil )
		[_answerString setString:(NSString *)[_question answer]];
	*/
	_needsReshape = YES;
	[self setNeedsDisplay:YES];
}

- (void)setBoardViewState:(TIPTriviaBoardViewState)newState
{
	if( newState == theViewState )
		return;
	// for transition animations
	theViewState = newState;
	
	[_transitionAnimation setCurrentProgress:0.0];
	[_transitionAnimation startAnimation];
	
	[self setNeedsDisplay:YES];
}

-  (void)animationTick:(TransitionAnimation *)theAnimation
{
	[self setNeedsDisplay:YES];
}

#pragma mark Trivia Show Methods

- (void)showPlaceholder
{
	[self setBoardViewState:kTIPTriviaBoardViewStatePlaceholder];
}

- (void)showBoard
{
	if( _mainBoard != nil )
		[self setBoardViewState:kTIPTriviaBoardViewStateBoard];
	else
		[self setBoardViewState:kTIPTriviaBoardViewStatePlaceholder];
}

- (void)showPlayers
{
	[self setBoardViewState:kTIPTriviaBoardViewStatePlayers];
	
	NSMutableArray *topScorers = [NSMutableArray arrayWithArray:_players];
	[topScorers sortUsingSelector:@selector(sortByPoints:)];
	
	while( [topScorers count] > 4 )
		[topScorers removeObjectAtIndex:4];
	
	NSEnumerator *playerEnumerator = [topScorers objectEnumerator];
	TriviaPlayer *aPlayer;
	while( (aPlayer = [playerEnumerator nextObject]) ) {
		StringTexture *aNameTexture = [[StringTexture alloc] initWithString:[aPlayer name] withSize:[_playerNameBox size] withFontSize:ceilf([_playerNameBox size].height*0.8f)];
		[[aNameTexture textContainer] setTruncates:YES];
		[aNameTexture setFontSize:ceilf([_playerNameBox size].height*0.7f)];
		[_playerNameStrings addObject:aNameTexture];
		StringTexture *aPointTexture = [[StringTexture alloc] initWithString:[NSString stringWithFormat:@"%d",[aPlayer points]] withSize:[_playerNameBox size] withFontSize:ceilf([_playerPointBox size].height*0.8f)];
		[_playerPointStrings addObject:aPointTexture];
	}
}

- (void)showQuestion
{
	// generate a texture for the question we have
	_questionScene = [[TriviaSceneQA alloc] init];
	[_questionScene setTitle:@"Questsion" text:(NSString *)[_question question]];
	[_questionScene setSize:_targetSize];
	[_questionScene buildTexture];
	[self setBoardViewState:kTIPTriviaBoardViewStateQuestion];
}

- (void)showAnswer
{
	// generate a texture for the answer we have
	_answerScene = [[TriviaSceneQA alloc] init];
	[_answerScene setTitle:@"Answer" text:[_question answer]];
	[_answerScene setSize:_targetSize];
	[_answerScene setProgress:0.0f];
	[_answerScene buildTexture];
	[self setBoardViewState:kTIPTriviaBoardViewStateAnswer];
}

- (void)pause
{
	[_transitionAnimation pause];
}

@end

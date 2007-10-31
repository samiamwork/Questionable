//
//  TriviaBoardOpenGLView.m
//  Questionable
//
//  Created by Nur Monson on 2/20/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TriviaBoardOpenGLView.h"

@interface NSObject (Delegate)
- (void)triviaBoardViewTransitionDone:(TriviaBoardOpenGLView *)aView;
@end

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
		_playersScene = nil;
		_scale = 1.0f;

		//_transitionDoneCallback = nil;
		_delegate = nil;
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
	[_playersScene release];

	//[_transitionDoneCallback release];

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
		_adjustedOrigin = NSMakePoint(0.0f,0.0f);
	} else if( _targetSize.width < _contextSize.width ) {
		float dx = (_contextSize.width - _targetSize.width)/2.0f;
		glOrtho(0.0f-dx, _targetSize.width+dx, 0.0f, _contextSize.height, 300.0f, -300.0f);
		_adjustedOrigin = NSMakePoint(-dx,0.0f);
	} else if( _targetSize.height < _contextSize.height ) {
		float dy = (_contextSize.height - _targetSize.height)/2.0f;
		glOrtho(0.0f, _contextSize.width, 0.0f-dy, _targetSize.height+dy, 300.0f, -300.0f);
		_adjustedOrigin = NSMakePoint(0.0f,-dy);
	} else {
		glOrtho(0.0f, _contextSize.width, 0.0f, _contextSize.height, 300.0f, -300.0f);
	}
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	_scale = _targetSize.width/640.0f;
	glScalef(_scale,_scale,_scale);
	
	[_boardScene setScale:_scale];
	[_placeholderScene setScale:_scale];
	[_questionScene setScale:_scale];
	[_answerScene setScale:_scale];
	[_playersScene setScale:_scale];
	
	_needsReshape = NO;
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

- (void)drawState:(TIPTriviaBoardViewState)aState withProgress:(float)progress
{
	glPushMatrix();
	glTranslatef((_contextSize.width/_scale)*progress,0.0f,0.0f);
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
			[_playersScene draw];
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
				[_playersScene release];
				_playersScene = nil;
				break;
			case kTIPTriviaBoardViewStatePlaceholder:
				break;
			default:
				break;
		}
		
		lastViewState = theViewState;
		// TODO: change this to use a delegate
		if( _delegate && [_delegate respondsToSelector:@selector(triviaBoardViewTransitionDone:)] )
			[_delegate triviaBoardViewTransitionDone:self];
		/*
		if( _transitionDoneCallback )
			[_transitionDoneCallback invoke];
		 */
	}
	
	glPushMatrix();
	glScalef(1.0f/_scale,1.0f/_scale,1.0f/_scale);
	glBegin(GL_TRIANGLE_STRIP); {
		glColor4f(0.3f,0.3f,0.3f,1.0f);
		glVertex2f(_adjustedOrigin.x, _adjustedOrigin.y);
		glVertex2f(_adjustedOrigin.x+_contextSize.width, _adjustedOrigin.y);
		glColor4f(0.0f,0.0f,0.0f,1.0f);
		glVertex2f(_adjustedOrigin.x,_adjustedOrigin.y+_contextSize.height*0.4f);
		glVertex2f(_adjustedOrigin.x+_contextSize.width,_adjustedOrigin.y+_contextSize.height*0.4f);
	} glEnd();
	glPopMatrix();
	
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
	_categories = nil;
	if( _mainBoard == nil ) {
		[self setNeedsDisplay:YES];
		return;
	}
	
	NSData *licenseData = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"license"];
	NSData *badData = [NSData data];
	// if unregistered insert the "unregistered" category
	if( APVerifyLicenseData((CFDataRef )badData) ||
		!APVerifyLicenseData((CFDataRef )licenseData) ) {
		TriviaCategory *dummyCategory = [[TriviaCategory alloc] init];
		[dummyCategory setTitle:@"Please Register"];
		
		NSEnumerator *questionEnumerator = [[dummyCategory questions] objectEnumerator];
		TriviaQuestion *aQuestion;
		while( (aQuestion = [questionEnumerator nextObject]) ) {
			[aQuestion setQuestion:@"How much does Questionable cost?"];
			[aQuestion setAnswer:@"$25"];
		}
		
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
/*
- (void)setTransitionDoneCallback:(NSInvocation *)callback
{
	if( callback == _transitionDoneCallback )
		return;
	
	[_transitionDoneCallback release];
	_transitionDoneCallback = [callback retain];
}
*/
- (void)setDelegate:(id)theDelegate
{
	// weak reference
	_delegate = theDelegate;
}

- (void)refresh
{
	// update any values currently on display
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
	_playersScene = [[TriviaScenePlayers alloc] init];
	//[_playersScene setSize:_targetSize];
	[_playersScene setScale:_scale];
	[_playersScene setPlayers:_players];
	[_playersScene buildTexture];
	
	[self setBoardViewState:kTIPTriviaBoardViewStatePlayers];
}

- (void)showQuestion
{
	// generate a texture for the question we have
	_questionScene = [[TriviaSceneQA alloc] init];
	[_questionScene setTitle:@"Question" text:(NSString *)[_question question]];
	//[_questionScene setSize:_targetSize];
	[_questionScene setScale:_scale];
	[_questionScene buildTexture];
	[self setBoardViewState:kTIPTriviaBoardViewStateQuestion];
}

- (void)showAnswer
{
	// generate a texture for the answer we have
	_answerScene = [[TriviaSceneQA alloc] init];
	[_answerScene setTitle:@"Answer" text:[_question answer]];
	//[_answerScene setSize:_targetSize];
	[_answerScene setScale:_scale];
	[_answerScene setProgress:0.0f];
	[_answerScene buildTexture];
	[self setBoardViewState:kTIPTriviaBoardViewStateAnswer];
}

- (void)pause
{
	[_transitionAnimation pause];
}

@end

//
//  TriviaBoardOpenGLView.m
//  Questionable
//
//  Created by Nur Monson on 2/20/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TriviaBoardOpenGLView.h"


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
		
		_windowedPixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:windowedAttributes] autorelease];
		_windowedContext = [[NSOpenGLContext alloc] initWithFormat:_windowedPixelFormat shareContext:nil];
		
		if( !_windowedContext ) {
			printf("error creating windowed OpenGL contex\n");
			[self dealloc];
			return nil;
		}
		
		long vsync = 1;
		[_windowedContext setValues:&vsync forParameter:NSOpenGLCPSwapInterval];
		
		_preserveTargetAspectRatio = YES;
		_targetAspectRatio = 640.0f/480.0f;
		_needsReshape = NO;
		_isFirstFrame = YES;
		
		//Trivia Objects
		_mainBoard = nil;
		_question = nil;
		_players = nil;
		_transitionAnimation = [[NSAnimation alloc] initWithDuration:0.5f animationCurve:NSAnimationEaseInOut];
		[_transitionAnimation setAnimationBlockingMode:NSAnimationNonblocking];
		
		theViewState = lastViewState = kTIPTriviaBoardViewStatePlaceholder;
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
	
	[self setNeedsDisplay:YES];
}

- (void)firstFrameSetup
{
	[_windowedContext setView:self];
	[_windowedContext makeCurrentContext];
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
	
	_contextSize = NSZeroSize;
	
	_isFirstFrame = NO;
	_needsReshape = YES;
}

- (void)drawState:(TIPTriviaBoardViewState)aState withProgress:(float)progress
{
	switch( aState ) {
		case kTIPTriviaBoardViewStateBoard:
			glColor4f( 1.0f,0.0f,0.5f,progress );
			break;
		case kTIPTriviaBoardViewStateQuestion:
			glColor4f( 0.0f,0.1f,0.5f,progress );
			break;
		case kTIPTriviaBoardViewStateAnswer:
			glColor4f( 0.5f,0.0f,0.1f,progress );
			break;
		case kTIPTriviaBoardViewStatePlayers:
			glColor4f( 1.0f,0.0f,0.5f,progress );
			break;
		case kTIPTriviaBoardViewStatePlaceholder:
		default:
			glColor4f( 0.8f,0.8f,0.8f,progress );
			break;
	}
	
	glBegin(GL_TRIANGLE_FAN); {
		glVertex2f(0.0f,0.0f);
		glVertex2f(_targetSize.width,0.0f);
		glVertex2f(_targetSize.width,_targetSize.height);
		glVertex2f(0.0f,_targetSize.height);
	} glEnd();
}

- (void)drawRect:(NSRect)rect
{
	if( _isFirstFrame )
		[self firstFrameSetup];
	
	NSSize boundSize = [self bounds].size;
	if( _contextSize.width != boundSize.width || _contextSize.height != boundSize.height )
		[self doReshape];
	
	glClearColor(0.5f,0.0f,0.0f,1.0f);
	glClear( GL_COLOR_BUFFER_BIT );
	
	if( theViewState != lastViewState ) {
		float progress = [_transitionAnimation currentProgress];
		[self drawState:lastViewState withProgress:(1.0f-progress)];
		[self drawState:theViewState withProgress:progress];
		
		if( ![_transitionAnimation isAnimating] ) {
			lastViewState = theViewState;
			if( _transitionTimer != nil )
				[_transitionTimer invalidate];
			_transitionTimer = nil;
		}
	} else {
		[self drawState:theViewState withProgress:1.0f];
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

- (void)setBoardViewState:(TIPTriviaBoardViewState)newState
{
	if( newState == theViewState )
		return;
	// for transition animations
	theViewState = newState;
	
	if( _transitionTimer != nil )
		[_transitionTimer invalidate];
	_transitionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(transitionUpdate:) userInfo:nil repeats:YES];
	[_transitionAnimation setCurrentProgress:0.0];
	[_transitionAnimation startAnimation];
	
	[self setNeedsDisplay:YES];
}

- (void)transitionUpdate:(NSTimer *)aTimer
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
}

- (void)showQuestion
{
	// generate a texture for the question we have
	[self setBoardViewState:kTIPTriviaBoardViewStateQuestion];
}

- (void)showAnswer
{
	// generate a texture for the answer we have
	[self setBoardViewState:kTIPTriviaBoardViewStateAnswer];
}

@end

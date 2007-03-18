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
		_targetAspectRatio = 640.0f/480.0f;
		_needsReshape = NO;
		_isFirstFrame = YES;
		
		//Trivia Objects
		_mainBoard = nil;
		_question = nil;
		_players = nil;
		_transitionAnimation = [[NSAnimation alloc] initWithDuration:0.5 animationCurve:NSAnimationEaseInOut];
		[_transitionAnimation setAnimationBlockingMode:NSAnimationNonblocking];
		
		theViewState = lastViewState = kTIPTriviaBoardViewStatePlaceholder;
		
		//Display Objects
		_categoryTitleBox = [[RectangularBox alloc] init];
		[_categoryTitleBox setSharpCorners:BoxCornerLowerLeft|BoxCornerLowerRight];
		[_categoryTitleBox setStartColor:[NSColor colorWithCalibratedRed:0.2f green:0.2f blue:0.7f alpha:1.0f]];
		[_categoryTitleBox setEndColor:[NSColor colorWithCalibratedRed:0.4f green:0.4f blue:0.9f alpha:1.0f]];
		[_categoryTitleBox setLineWidth:1.0f];

		_pointsBox = [[RectangularBox alloc] init];
		[_pointsBox setSharpCorners:BoxCornerAll];
		[_pointsBox setStartColor:[NSColor colorWithCalibratedRed:0.2f green:0.2f blue:0.7f alpha:1.0f]];
		[_pointsBox setEndColor:[NSColor colorWithCalibratedRed:0.4f green:0.4f blue:0.9f alpha:1.0f]];
		[_pointsBox setLineWidth:1.0f];
		[_pointsBox setCornerRadius:10.0f];
		[_pointsBox setShadingDirection:BoxShadingHorizontal];
		
		_categoryTitleStrings = [[NSMutableArray alloc] init];
		_questionPointStrings = [[NSMutableArray alloc] init];
		
		_QATitleBox = nil;
		_QATitleBox = [[RectangularBox alloc] init];
		[_QATitleBox setSharpCorners:BoxCornerLowerLeft|BoxCornerLowerRight];
		
		_QATextBox = nil;
		_questionString = nil;
		_answerString = nil;
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
	[_categoryTitleBox release];
	[_pointsBox release];
	[_categoryTitleStrings release];
	[_questionPointStrings release];

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
	[_categoryTitleStrings removeAllObjects];
	NSEnumerator *categoryEnumerator = [[_mainBoard categories] objectEnumerator];
	TriviaCategory *aCategory;
	while( (aCategory = [categoryEnumerator nextObject]) ) {
		StringTexture *aStringTexture = [[StringTexture alloc] initWithString:[aCategory title] withWidth:_titleStringSize.width withFontSize:_titleStringSize.height];
		[aStringTexture setColor:[NSColor colorWithCalibratedWhite:1.0f alpha:1.0f]];
		[_categoryTitleStrings addObject:aStringTexture];
		[aStringTexture release];
	}
	
	[_questionPointStrings removeAllObjects];
	unsigned int points;
	for( points = 100; points <= 500; points += 100 ) {
		StringTexture *aStringTexture = [[StringTexture alloc] initWithString:[[NSNumber numberWithInt:points] stringValue]
																	withWidth:_pointStringSize.width
																 withFontSize:_pointStringSize.height];
		[aStringTexture setFont:[NSFont fontWithName:@"Helvetica-Bold" size:12.0f]];
		[_questionPointStrings addObject:aStringTexture];
		[aStringTexture release];
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
	
	// recalculate display metrics
	_boardPaddingSize = NSMakeSize(15.0f,-2.0f);
	_boardMarginSize = NSMakeSize(10.0f,25.0f);
	NSSize availableSize = NSMakeSize(_targetSize.width - 2.0f*_boardMarginSize.width - 4.0f*_boardPaddingSize.width,
									  _targetSize.height - 2.0f*_boardMarginSize.height - 5.0f*_boardPaddingSize.height);
	_questionTitleSize.width = floorf(availableSize.width/5.0f);
	_questionTitleSize.height = floorf(availableSize.height/5.0f);
	_questionPointSize.width = _questionTitleSize.width;
	_questionPointSize.height = floorf( (availableSize.height - _questionTitleSize.height)/5.0f );
	
	_titleStringSize = NSMakeSize(floorf(_questionTitleSize.width*0.9f),floorf(_questionTitleSize.height*0.9f/4.0f));
	_pointStringSize = NSMakeSize(floorf(_questionPointSize.width*0.9f),floorf(_questionPointSize.height*0.6f));
	
	// set new sizes
	[_categoryTitleBox setSize:_questionTitleSize];
	[_categoryTitleBox setCornerRadius:floorf(_questionTitleSize.height*0.2f)];
	
	[_pointsBox setSize:_questionPointSize];
	
	[_QATitleBox setSize:availableSize];
	[_QATitleBox setCornerRadius:ceilf(availableSize.height/2.0f)];
	[_QATitleBox setLineWidth:ceilf(availableSize.height*0.02f)];
	
	[self regenerateStringTextures];
	
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
	glDisable(GL_DEPTH_TEST);
	
	_contextSize = NSZeroSize;
	
	_isFirstFrame = NO;
	_needsReshape = YES;
}

- (void)drawState:(TIPTriviaBoardViewState)aState withProgress:(float)progress
{
	switch( aState ) {
		case kTIPTriviaBoardViewStateBoard:
			glPushMatrix();
			glTranslatef(-_contextSize.width*(1.0f-progress),0.0f,0.0f);
			float startHorizontal = _boardMarginSize.width + (_targetSize.width - 2.0f*_boardMarginSize.width - (float)[_categoryTitleStrings count]*_questionTitleSize.width - (float)([_categoryTitleStrings count]-1)*_boardPaddingSize.width)/2.0f;
			glTranslatef(startHorizontal,_targetSize.height-_boardMarginSize.height-_questionTitleSize.height,0.0f);
			NSEnumerator *titleEnumerator = [_categoryTitleStrings objectEnumerator];
			StringTexture *aTitleString;
			while( (aTitleString = [titleEnumerator nextObject]) ) {
				[_categoryTitleBox drawWithString:aTitleString];
				
				glPushMatrix();
				glTranslatef(0.0f,-(_boardPaddingSize.height+_questionPointSize.height),0.0f);
				NSEnumerator *pointEnumerator = [_questionPointStrings objectEnumerator];
				StringTexture *aPointTexture;
				while( (aPointTexture = [pointEnumerator nextObject]) ) {
					[_pointsBox drawWithString:aPointTexture];
					glTranslatef(0.0f,-(_boardPaddingSize.height+_questionPointSize.height),0.0f);
				}
				glPopMatrix();
				glTranslatef(_questionTitleSize.width+_boardPaddingSize.width,0.0f,0.0f);
			}
			glPopMatrix();
			break;
		case kTIPTriviaBoardViewStateQuestion:
			glColor4f( 0.0f,0.1f,0.5f,progress );
			glBegin(GL_TRIANGLE_FAN); {
				glVertex2f(0.0f,0.0f);
				glVertex2f(_targetSize.width,0.0f);
				glVertex2f(_targetSize.width,_targetSize.height);
				glVertex2f(0.0f,_targetSize.height);
			} glEnd();			
			break;
		case kTIPTriviaBoardViewStateAnswer:
			glColor4f( 0.5f,0.0f,0.1f,progress );
			glBegin(GL_TRIANGLE_FAN); {
				glVertex2f(0.0f,0.0f);
				glVertex2f(_targetSize.width,0.0f);
				glVertex2f(_targetSize.width,_targetSize.height);
				glVertex2f(0.0f,_targetSize.height);
			} glEnd();			
			break;
		case kTIPTriviaBoardViewStatePlayers:
			glColor4f( 1.0f,0.0f,0.5f,progress );
			glBegin(GL_TRIANGLE_FAN); {
				glVertex2f(0.0f,0.0f);
				glVertex2f(_targetSize.width,0.0f);
				glVertex2f(_targetSize.width,_targetSize.height);
				glVertex2f(0.0f,_targetSize.height);
			} glEnd();			
			break;
		case kTIPTriviaBoardViewStatePlaceholder:
		default:
			glColor4f( 0.0f,0.8f,0.8f, progress ); 
			glBegin(GL_TRIANGLE_FAN); {
				glVertex2f(0.0f,0.0f);
				glVertex2f(_targetSize.width,0.0f);
				glVertex2f(_targetSize.width,_targetSize.height);
				glVertex2f(0.0f,_targetSize.height);
			} glEnd();
			break;
	}
	
}

- (void)drawRect:(NSRect)rect
{
	if( _isFirstFrame )
		[self firstFrameSetup];
	
	NSSize boundSize = [self bounds].size;
	if( _contextSize.width != boundSize.width || _contextSize.height != boundSize.height )
		[self doReshape];
	
	glClearColor(0.0f,0.0f,0.0f,1.0f);
	glClear( GL_COLOR_BUFFER_BIT );
	
	if( ![_transitionAnimation isAnimating] ) {
		lastViewState = theViewState;
		if( _transitionTimer != nil )
			[_transitionTimer invalidate];
		_transitionTimer = nil;
	}
	
	if( theViewState != lastViewState ) {
		float progress = [_transitionAnimation currentValue];
		[self drawState:lastViewState withProgress:(1.0f-progress)];
		[self drawState:theViewState withProgress:progress];
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
	
	[self regenerateStringTextures];
	
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

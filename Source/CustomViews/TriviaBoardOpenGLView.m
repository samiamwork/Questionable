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
		[_categoryTitleBox setStartColor:[NSColor colorWithCalibratedRed:0.2f green:0.35f blue:0.5f alpha:1.0f]];
		[_categoryTitleBox setEndColor:[NSColor colorWithCalibratedRed:0.3f green:0.3f blue:0.4f alpha:1.0f]];
		[_categoryTitleBox setLineWidth:1.0f];

		_pointsBox = [[RectangularBox alloc] init];
		[_pointsBox setSharpCorners:BoxCornerAll];
		[_pointsBox setStartColor:[NSColor colorWithCalibratedRed:46.0f/255.0f green:83.0f/255.0f blue:145.0f/255.0f alpha:1.0f]];
		[_pointsBox setEndColor:[NSColor colorWithCalibratedRed:92.0f/255.0f green:142.0f/255.0f blue:251.0f/255.0f alpha:1.0f]];
		[_pointsBox setLineWidth:1.0f];
		[_pointsBox setCornerRadius:10.0f];
		[_pointsBox setShadingDirection:BoxShadingHorizontal];
		
		_categoryTitleStrings = [[NSMutableArray alloc] init];
		_questionPointStrings = [[NSMutableArray alloc] init];
		_questionTitleString = nil;
		_answerTitleString = nil;
		_questionString = nil;
		_answerString = nil;
		
		_QATitleBox = [[RectangularBox alloc] init];
		[_QATitleBox setStartColor:[NSColor colorWithCalibratedRed:0.2f green:0.25f blue:0.55f alpha:1.0f]];
		[_QATitleBox setEndColor:[NSColor colorWithCalibratedRed:0.3f green:0.35f blue:0.65f alpha:1.0f]];
		[_QATitleBox setSharpCorners:BoxCornerLowerLeft|BoxCornerLowerRight];
		[_QATitleBox setLineWidth:1.0f];
		_QATextBox = [[RectangularBox alloc] init];
		[_QATextBox setStartColor:[NSColor colorWithCalibratedRed:46.0f/255.0f green:83.0f/255.0f blue:145.0f/255.0f alpha:1.0f]];
		[_QATextBox setEndColor:[NSColor colorWithCalibratedRed:92.0f/255.0f green:142.0f/255.0f blue:251.0f/255.0f alpha:1.0f]];
		[_QATextBox setSharpCorners:BoxCornerUpperLeft|BoxCornerUpperRight];
		[_QATextBox setLineWidth:1.0f];
		
		_questionString = nil;
		_answerString = nil;
		
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
		
		_placeholderCircleOuter = [[RectangularBox alloc] init];
		[_placeholderCircleOuter setLineWidth:10.0f];
		[_placeholderCircleOuter enableBorder:NO];
		_placeholderCircleInner = [[RectangularBox alloc] init];
		[_placeholderCircleInner setLineWidth:10.0f];
		_questionmark = [[StringTexture alloc] initWithString:@"?" withWidth:150.0f withFontSize:100.0f];
		[_questionmark setFont:[NSFont fontWithName:@"Helvetica-Bold" size:100.0f]];
		[_questionmark setColor:[NSColor whiteColor]];
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
	[_QATitleBox release];
	[_QATextBox release];
	[_questionString release];
	[_answerString release];
	[_answerTitleString release];
	[_questionTitleString release];
	[_categoryTitleStrings release];
	[_questionPointStrings release];
	
	[_playerNameBox release];
	[_playerPointBox release];
	[_playerNameStrings release];
	[_playerPointStrings release];
	
	[_placeholderCircleInner release];
	[_placeholderCircleOuter release];
	[_questionmark release];

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
	NSEnumerator *categoryTitleEnumerator = [_categoryTitleStrings objectEnumerator];
	StringTexture *aCategoryTitle;
	while( (aCategoryTitle = [categoryTitleEnumerator nextObject]) ) {
		[aCategoryTitle setWidth:_titleStringSize.width];
		[aCategoryTitle setFontSize:_titleStringSize.height];
	}
	
	NSEnumerator *pointEnumerator = [_questionPointStrings objectEnumerator];
	StringTexture *aPointString;
	while( (aPointString = [pointEnumerator nextObject]) ) {
		[aPointString setWidth:_pointStringSize.width];
		[aPointString setFontSize:_pointStringSize.height];
	}
	
	if( _questionTitleString != nil ) {
		[_questionTitleString setWidth:[_QATitleBox size].width];
		[_questionTitleString setFontSize:ceilf([_QATitleBox size].height*0.7f)];
	}
	if( _questionString != nil ) {
		[_questionString setWidth:ceilf([_QATextBox size].width*0.8f)];
		[_questionString setFontSize:ceilf([_QATextBox size].height/8.0f)];
	}
	
	if( _answerTitleString != nil ) {
		[_answerTitleString setWidth:[_QATitleBox size].width];
		[_answerTitleString setFontSize:ceilf([_QATitleBox size].height*0.7f)];
	}
	if( _answerString != nil ) {
		[_answerString setWidth:ceilf([_QATextBox size].width*0.8f)];
		[_answerString setFontSize:ceilf([_QATextBox size].height/8.0f)];
	}
	
	
	if( [_playerNameStrings count] != 0 ) {
		NSEnumerator *stringEnumerator = [_playerNameStrings objectEnumerator];
		StringTexture *aStringTexture;
		while( (aStringTexture = [stringEnumerator nextObject]) ) {
			[aStringTexture setWidth:floorf([_playerNameBox size].width)];
			[aStringTexture setFontSize:ceilf([_playerNameBox size].height*0.8f)];
		}
	}
	if( [_playerPointStrings count] != 0 ) {
		NSEnumerator *stringEnumerator = [_playerPointStrings objectEnumerator];
		StringTexture *aStringTexture;
		while( (aStringTexture = [stringEnumerator nextObject]) ) {
			[aStringTexture setWidth:floorf([_playerPointBox size].width)];
			[aStringTexture setFontSize:ceilf([_playerPointBox size].height*0.8f)];
		}
	}
	
	[_questionmark setFontSize:_targetSize.height*0.5f];
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
	
	[_QATitleBox setSize:NSMakeSize(_targetSize.width-2.0f*_boardMarginSize.width, availableSize.height*0.2f)];
	[_QATitleBox setCornerRadius:[_QATitleBox size].height*0.4f];
	//[_QATitleBox setLineWidth:ceilf(availableSize.height*0.005f)];
	
	[_QATextBox setSize:NSMakeSize([_QATitleBox size].width,availableSize.height*0.8f)];
	[_QATextBox setCornerRadius:[_QATitleBox cornerRadius]];
	//[_QATextBox setLineWidth:[_QATitleBox lineWidth]];
	
	_playerNameSize = NSMakeSize(_targetSize.width-2.0f*_boardMarginSize.width,ceilf(((_targetSize.height-_boardMarginSize.height*2.0f)/4.0f)*0.5f));
	_playerPointSize = NSMakeSize(_playerNameSize.width,ceilf(((_targetSize.height-_boardMarginSize.height*2.0f)/4.0f)*0.3f));
	_playerPointPadding = ceilf(((_targetSize.height-_boardMarginSize.height*2.0f)/4.0f)*0.2f);
	[_playerNameBox setSize:_playerNameSize];
	[_playerPointBox setSize:_playerPointSize];
	[_playerPointBox setCornerRadius:ceilf(_playerPointSize.height*0.4f)];
	
	[_placeholderCircleOuter setSize:NSMakeSize(_targetSize.height*0.5f,_targetSize.height*0.5f)];
	[_placeholderCircleOuter setCornerRadius:[_placeholderCircleOuter size].width/2.0f];
	[_placeholderCircleInner setSize:NSMakeSize([_placeholderCircleOuter size].width*0.5f,[_placeholderCircleOuter size].height*0.5f)];
	[_placeholderCircleInner setCornerRadius:[_placeholderCircleInner size].width/2.0f];
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
	switch( aState ) {
		case kTIPTriviaBoardViewStateBoard:
			glPushMatrix();
			glTranslatef(_contextSize.width*progress,0.0f,0.0f);
			float startHorizontal = _boardMarginSize.width + (_targetSize.width - 2.0f*_boardMarginSize.width - (float)[_categoryTitleStrings count]*_questionTitleSize.width - (float)([_categoryTitleStrings count]-1)*_boardPaddingSize.width)/2.0f;
			glTranslatef(startHorizontal,_targetSize.height-_boardMarginSize.height-_questionTitleSize.height,0.0f);
			unsigned int categoryIndex;
			for( categoryIndex = 0; categoryIndex < [[_mainBoard categories] count]; categoryIndex++ ) {
				TriviaCategory *aCategory = [[_mainBoard categories] objectAtIndex:categoryIndex];
				[_categoryTitleBox drawWithString:[_categoryTitleStrings objectAtIndex:categoryIndex]];
				
				glPushMatrix();
				glTranslatef(0.0f,-(_boardPaddingSize.height+_questionPointSize.height),0.0f);
				unsigned int questionIndex;
				for( questionIndex = 0; questionIndex < [[aCategory questions] count]; questionIndex++ ) {
					StringTexture *aStringTexture = nil;
					if( ! [[[aCategory questions] objectAtIndex:questionIndex] used] )
						aStringTexture = [_questionPointStrings objectAtIndex:questionIndex];
					[_pointsBox drawWithString:aStringTexture];
					glTranslatef(0.0f,-(_boardPaddingSize.height+_questionPointSize.height),0.0f);
				}
				glPopMatrix();
				glTranslatef(_questionTitleSize.width+_boardPaddingSize.width,0.0f,0.0f);
			}
			glPopMatrix();
			break;
		case kTIPTriviaBoardViewStateQuestion:
			glPushMatrix();
			glTranslatef(_contextSize.width*progress,0.0f,0.0f);
			glTranslatef(_boardMarginSize.width,_targetSize.height-_boardMarginSize.height-[_QATitleBox size].height,0.0f);
			[_QATitleBox drawWithString:_questionTitleString];
			glTranslatef(0.0f,-[_QATextBox size].height+[_QATextBox lineWidth],0.0f);
			[_QATextBox drawWithString:_questionString];
			glPopMatrix();
			break;
		case kTIPTriviaBoardViewStateAnswer:
			glPushMatrix();
			glTranslatef(_contextSize.width*progress,0.0f,0.0f);
			glTranslatef(_boardMarginSize.width,_targetSize.height-_boardMarginSize.height-[_QATitleBox size].height,0.0f);
			[_QATitleBox drawWithString:_answerTitleString];
			glTranslatef(0.0f,-[_QATextBox size].height+[_QATextBox lineWidth],0.0f);
			[_QATextBox drawWithString:_answerString];
			glPopMatrix();
			break;
		case kTIPTriviaBoardViewStatePlayers:
			glPushMatrix();
			glTranslatef(_contextSize.width*progress,0.0f,0.0f);
			glTranslatef(_boardMarginSize.width,_targetSize.height-_boardMarginSize.height-[_playerNameBox size].height,0.0f);
			[self drawPlayerStatus];
			glPopMatrix();
			break;
		case kTIPTriviaBoardViewStatePlaceholder:
		default:
			glPushMatrix();
			[_placeholderCircleOuter drawWithString:nil];
			glPopMatrix();
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
	
	if( lastViewState != theViewState && ![_transitionAnimation isAnimating] ) {
		switch(lastViewState) {
			case kTIPTriviaBoardViewStateQuestion:
				if( _questionString != nil )
					[_questionString release];
				_questionString = nil;
				[_questionTitleString release];
				_questionTitleString = nil;
				break;
			case kTIPTriviaBoardViewStateAnswer:
				if( _answerString != nil )
					[_answerString release];
				_answerString = nil;
				[_answerTitleString release];
				_answerTitleString = nil;
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
		if( _transitionTimer != nil )
			[_transitionTimer invalidate];
		_transitionTimer = nil;
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
	
	NSMutableArray *topScorers = [NSMutableArray arrayWithArray:_players];
	[topScorers sortUsingSelector:@selector(sortByPoints:)];
	
	while( [topScorers count] > 4 )
		[topScorers removeObjectAtIndex:4];
	
	NSEnumerator *playerEnumerator = [topScorers objectEnumerator];
	TriviaPlayer *aPlayer;
	while( (aPlayer = [playerEnumerator nextObject]) ) {
		StringTexture *aNameTexture = [[StringTexture alloc] initWithString:[aPlayer name] withWidth:[_playerNameBox size].width withFontSize:ceilf([_playerNameBox size].height*0.8f)];
		[_playerNameStrings addObject:aNameTexture];
		StringTexture *aPointTexture = [[StringTexture alloc] initWithString:[NSString stringWithFormat:@"%d",[aPlayer points]] withWidth:[_playerNameBox size].width withFontSize:ceilf([_playerPointBox size].height*0.8f)];
		[_playerPointStrings addObject:aPointTexture];
	}
}

- (void)showQuestion
{
	// generate a texture for the question we have
	[self setBoardViewState:kTIPTriviaBoardViewStateQuestion];
	if( [_question question] != nil )
		_questionString = [[StringTexture alloc] initWithString:(NSString *)[_question question] withWidth:ceilf([_QATextBox size].width*0.8f) withFontSize:ceil([_QATextBox size].height/8.0f)];
	_questionTitleString = [[StringTexture alloc] initWithString:@"Question" withWidth:[_QATitleBox size].width withFontSize:ceilf([_QATitleBox size].height*0.7f)];
	[_questionTitleString setColor:[NSColor colorWithCalibratedWhite:0.9f alpha:0.9f]];
}

- (void)showAnswer
{
	// generate a texture for the answer we have
	[self setBoardViewState:kTIPTriviaBoardViewStateAnswer];
	if( [_question answer] != nil )
		_answerString = [[StringTexture alloc] initWithString:(NSString *)[_question answer] withWidth:ceilf([_QATextBox size].width*0.8f) withFontSize:ceil([_QATextBox size].height/8.0f)];
	_answerTitleString = [[StringTexture alloc] initWithString:@"Answer" withWidth:[_QATitleBox size].width withFontSize:ceilf([_QATitleBox size].height*0.7f)];
	[_answerTitleString setColor:[NSColor colorWithCalibratedWhite:0.9f alpha:0.9f]];
}

@end
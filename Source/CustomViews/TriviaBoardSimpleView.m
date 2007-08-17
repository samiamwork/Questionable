//
//  TriviaBoardSimpleView.m
//  TriviaPlayer
//
//  Created by Nur Monson on 10/19/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaBoardSimpleView.h"
#import "TIPGradient.h"

#define TITLEFRACT 0.2f

@interface NSObject (TriviaViewDelegateMethods)
- (void)questionSelected:(unsigned)questionIndex inCategory:(unsigned)categoryIndex;
@end

@implementation TriviaBoardSimpleView

- (id)initWithFrame:(NSRect)frameRect
{
	if( (self = [super initWithFrame:frameRect]) ) {
		_viewState = kTriviaSimpleViewNothing;
		
		_question = nil;
		mainBoard = nil;
		titleArray = [[NSMutableArray alloc] init];
		pointArray = [[NSMutableArray alloc] init];
		questionsPerCategory = 0;
		
		placeholderMessage = [[TIPTextContainer alloc] init];
		[placeholderMessage setText:@"?"];
		[placeholderMessage setFontSize:frameRect.size.height/5.0f];
		[placeholderMessage setAlignment:kTIPTextAlignmentCenter];
		[placeholderMessage setColor:[NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:0.5f]];
		
		_leftTimerView = [[SimpleTimerView alloc] initWithFrame:NSMakeRect(0.0f,0.0f,25.0f,frameRect.size.height)];
		[_leftTimerView setAutoresizingMask:NSViewHeightSizable|NSViewMaxXMargin];
		[self addSubview:_leftTimerView];
		
		_rightTimerView = [[SimpleTimerView alloc] initWithFrame:NSMakeRect(frameRect.size.width-25.0f,0.0f,25.0f,frameRect.size.height)];
		[_rightTimerView setAutoresizingMask:NSViewHeightSizable|NSViewMinXMargin];
		[self addSubview:_rightTimerView];
	}
	
	return self;
}

- (void)dealloc
{	
	if( mainBoard != nil )
		[mainBoard release];
	if( _question != nil )
		[_question release];
	
	[placeholderMessage release];
	[titleArray release];
	[pointArray release];
	
	[_leftTimerView release];
	
	[super dealloc];
}

- (void)setDelegate:(id)newDelegate
{
	if( newDelegate == delegate )
		return;
	
	delegate = newDelegate;
}
- (id)delegate
{
	return delegate;
}

- (void)startTimerOfLength:(NSTimeInterval)theLength
{
	[_leftTimerView startTimerOfLength:theLength];
	[_rightTimerView startTimerOfLength:theLength];
}

- (void)stopTimer
{
	[_leftTimerView stopTimer];
	[_rightTimerView stopTimer];
}

- (void)resetTimer
{
	[_leftTimerView resetTimer];
	[_rightTimerView resetTimer];
}

- (void)pauseTimer
{
	[_leftTimerView pauseTimer];
	[_rightTimerView pauseTimer];
}

#pragma mark Board Methods

- (void)setBoard:(TriviaBoard *)newBoard
{
	if( newBoard == mainBoard )
		return;
	
	[mainBoard release];
	mainBoard = newBoard;
	
	if( mainBoard == nil ) {
		_viewState = kTriviaSimpleViewNothing;
		[self setNeedsDisplay:YES];
		[self stopTimer];
		return;
	}
	
	[mainBoard retain];
	
	TriviaCategory *thisCategory;
	NSEnumerator *categoryEnumerator = [[mainBoard categories] objectEnumerator];
	
	[titleArray removeAllObjects];
	while( (thisCategory = [categoryEnumerator nextObject]) ) {
		TIPTextContainer *newText = [TIPTextContainer containerWithString:[thisCategory title]];
		[newText setColor:[NSColor colorWithCalibratedWhite:1.0f alpha:0.8f]];
		
		[titleArray addObject:newText];
		if( [[thisCategory questions] count] > questionsPerCategory )
			questionsPerCategory = [[thisCategory questions] count];
		
	}

	[pointArray removeAllObjects];
	unsigned questionIndex;
	for( questionIndex = 0; questionIndex < questionsPerCategory; questionIndex++ ) {
		TIPTextContainer *newText = [TIPTextContainer containerWithString:[[NSNumber numberWithInt:questionIndex*100+100] stringValue]];
		[newText setFont:[NSFont fontWithName:@"Helvetica-Bold" size:15.0f]];
		[newText setColor:[NSColor colorWithCalibratedWhite:0.2f alpha:1.0f]];
		
		[pointArray addObject:newText];
	}
}
- (TriviaBoard *)board
{
	return mainBoard;
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

- (void)showBoard
{
	if( mainBoard == nil )
		_viewState = kTriviaSimpleViewNothing;
	else
		_viewState = kTriviaSimpleViewBoard;
	[self setNeedsDisplay:YES];
}
- (void)showQuestion
{
	if( _question == nil )
		[self showBoard];
	else
		_viewState = kTriviaSimpleViewQuestion;
	[self setNeedsDisplay:YES];
}
- (void)showAnswer
{
	if( _question == nil )
		[self showBoard];
	else
		_viewState = kTriviaSimpleViewAnswer;
	[self setNeedsDisplay:YES];
}

#pragma mark Drawing

- (void)drawBoard
{
	NSRect bounds = [self bounds];
	CGContextRef currentContext = [[NSGraphicsContext currentContext] graphicsPort];
	
	float titleHeight = bounds.size.height * TITLEFRACT;
	NSSize qSize;
	qSize.height = (bounds.size.height - titleHeight)/questionsPerCategory;
	qSize.width = bounds.size.width/(float)[[mainBoard categories] count];
	CGRect currentRect = CGRectMake(0.0f, bounds.size.height-titleHeight, qSize.width, titleHeight);
	
	//draw category bar gradient
	TIPMutableGradientRef categoryGradient = TIPMutableGradientCreate();
	TIPGradientAddRGBColorStop(categoryGradient, 0.0f, 0.76f,0.76f,0.76f,1.0f);
	TIPGradientAddRGBColorStop(categoryGradient, 0.39f, 0.37f,0.37f,0.37f,1.0f);
	TIPGradientAddRGBColorStop(categoryGradient, 0.83f, 0.47f,0.47f,0.47f,1.0f);
	TIPGradientAddRGBColorStop(categoryGradient, 1.0f, 0.69f,0.69f,0.69f,1.0f);
	TIPGradientAxialFillRect(currentContext, categoryGradient, CGRectMake(0.0f,bounds.size.height-titleHeight,bounds.size.width,titleHeight),90.0f);
	TIPGradientRelease(categoryGradient);
	
	CGContextSetRGBStrokeColor(currentContext,0.0f,0.0f,0.0f,0.3f);
	CGContextSetLineWidth(currentContext,3.0f);
	CGContextSetRGBFillColor(currentContext, 0.5f,0.5f,0.5f,0.1f);
	CGContextMoveToPoint(currentContext,currentRect.origin.x,currentRect.origin.y);
	CGContextAddLineToPoint(currentContext,currentRect.origin.x+bounds.size.width,currentRect.origin.y);
	CGContextStrokePath(currentContext);
	
	
	unsigned categoryIndex;
	for( categoryIndex = 0; categoryIndex<[[mainBoard categories] count]; categoryIndex++ ) {
		TIPTextContainer *thisText = [titleArray objectAtIndex:categoryIndex];
		
		currentRect.size.height = titleHeight;
		currentRect.origin.y = bounds.size.height - titleHeight;
		
		[thisText setFontSize:currentRect.size.height/2.0f];
		NSRect insetTitleRect = NSInsetRect(*(NSRect *)&currentRect, 4.0f, 4.0f);
		[thisText fitTextInRect:insetTitleRect];
		//
		[thisText setColor:[NSColor colorWithCalibratedWhite:1.0f alpha:0.8f]];
		[thisText drawTextInRect:insetTitleRect inContext:currentContext];
		
		currentRect.origin.y -= qSize.height;
		currentRect.size.height = qSize.height;
		unsigned questionIndex;
		for( questionIndex = 0; questionIndex<questionsPerCategory; questionIndex++ ) {
			TriviaQuestion *aQuestion = [[[[mainBoard categories] objectAtIndex:categoryIndex] questions] objectAtIndex:questionIndex];
			if( ! [aQuestion used] ) {
				TIPTextContainer *aPointText = [pointArray objectAtIndex:questionIndex];
				[aPointText setFontSize:qSize.height*0.7f];
				[aPointText drawTextInRect:*(NSRect *)&currentRect inContext:currentContext];
			}
			
			currentRect.origin.y -= qSize.height;
		}
		
		if( categoryIndex != [[mainBoard categories] count]-1 ) {
			CGContextSetLineWidth(currentContext, 1.0f);
			
			float lineXPosition = currentRect.origin.x+currentRect.size.width;
			CGContextSetRGBStrokeColor(currentContext,0.75f,0.75f,0.75f,1.0f);
			CGContextMoveToPoint(currentContext,lineXPosition-0.5f,bounds.origin.y);
			CGContextAddLineToPoint(currentContext,lineXPosition-0.5f,bounds.origin.y+bounds.size.height);
			CGContextStrokePath(currentContext);
			
			CGContextSetRGBStrokeColor(currentContext,0.4f,0.4f,0.4f,1.0f);
			CGContextMoveToPoint(currentContext,lineXPosition+0.5f,bounds.origin.y);
			CGContextAddLineToPoint(currentContext,lineXPosition+0.5f,bounds.origin.y+bounds.size.height);
			CGContextStrokePath(currentContext);
			
			CGContextSetLineWidth(currentContext, 4.0f);
		}
		
		currentRect.origin.x += qSize.width;
	}
}

- (void)drawString:(NSString *)aString withTitle:(NSString *)aTitle
{
	NSRect bounds = [self bounds];
	CGContextRef currentContext = [[NSGraphicsContext currentContext] graphicsPort];
	
	if( aTitle != nil ) {
		TIPTextContainer *answerTitle = [TIPTextContainer containerWithString:aTitle
																		color:[NSColor colorWithCalibratedWhite:0.3f alpha:0.3f]
																	 fontName:@"Helvetica-Bold"];
		[answerTitle setAlignment:kTIPTextAlignmentLeft];
		[answerTitle setFontSize:bounds.size.height*0.2f];
		[answerTitle drawTextInRect:NSMakeRect(bounds.origin.x,bounds.origin.y+bounds.size.height*0.85f,bounds.size.width,bounds.size.height*0.2f) inContext:currentContext];
	}
	
	if( aString == nil || [aString length] == 0 )
		return;
	
	TIPTextContainer *aTextContainer = [[TIPTextContainer alloc] init];
	[aTextContainer setText:aString];
	[aTextContainer setFontSize:bounds.size.height/20.0f];
	
	NSRect textRect = NSInsetRect(bounds,bounds.size.height*0.1f,bounds.size.height*0.1f);
	[aTextContainer fitTextInRect:textRect];
	
	if( [aTextContainer lineCount] > 1 )
		[aTextContainer setAlignment:kTIPTextAlignmentLeft];
	if( [aTextContainer fontSize] > textRect.size.height/5.0f)
		[aTextContainer setFontSize:textRect.size.height/5.0f];
	[aTextContainer setColor:[NSColor colorWithCalibratedWhite:0.31f alpha:0.9f]];
	[aTextContainer drawTextInRect:textRect
						 inContext:currentContext];
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

- (void)drawPlaceholder
{
	NSRect bounds = [self bounds];
	CGContextRef currentContext = [[NSGraphicsContext currentContext] graphicsPort];
	
	CGContextSetRGBFillColor(currentContext,0.2f,0.2f,0.2f,1.0f);
	[placeholderMessage setFontSize:bounds.size.height/4.0f];
	[placeholderMessage setColor:[NSColor blackColor]];
	[placeholderMessage drawTextInRect:NSMakeRect(bounds.origin.x+1.0f,bounds.origin.y-1.0f,bounds.size.width,bounds.size.height) inContext:currentContext];
	[placeholderMessage setColor:[NSColor whiteColor]];
	[placeholderMessage drawTextInRect:bounds inContext:currentContext];
}

- (void)drawRect:(NSRect)rect
{
	NSRect bounds = [self bounds];
	
	CGContextRef currentContext = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextClearRect(currentContext, *(CGRect *)&bounds);
	TIPMutableGradientRef bgGradient = TIPMutableGradientCreate();
	TIPGradientAddRGBColorStop(bgGradient,0.0f,0.9f,0.9f,0.9f,1.0f);
	TIPGradientAddRGBColorStop(bgGradient,1.0f,0.7f,0.7f,0.7f,1.0f);
	TIPGradientRadialFillRect(currentContext,bgGradient,*(CGRect *)&bounds,(CGPoint){bounds.size.width/2.0f,0.0f},sqrtf(bounds.size.width*bounds.size.width/4.0f + bounds.size.height*bounds.size.height));
	TIPGradientRelease(bgGradient);
	
	switch( _viewState ) {
		case kTriviaSimpleViewBoard:
			[self drawBoard];
			break;
		case kTriviaSimpleViewQuestion:
			[self drawString:(NSString *)[_question question] withTitle:@"Question"];
			break;
		case kTriviaSimpleViewAnswer:
			[self drawString:(NSString *)[_question answer] withTitle:@"Answer"];
			break;
		default:
			[self drawPlaceholder];
	}
	
}

#pragma mark mouse tracking

- (void)mouseUp:(NSEvent *)theEvent
{
	if( _viewState != kTriviaSimpleViewBoard || mainBoard == nil )
		return;
	
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSRect bounds = [self bounds];
	
	if( [self mouse:point inRect:bounds] == NO )
		return;
	
	// stop if it's in the title region
	float clickableHeight = bounds.size.height-(bounds.size.height*TITLEFRACT);
	if( point.y > clickableHeight )
		return;
	
	NSSize questionSize = NSMakeSize(bounds.size.width/(float)[[mainBoard categories] count], clickableHeight/questionsPerCategory);
	
	unsigned questionIndex = questionsPerCategory-1-(unsigned)(point.y/questionSize.height);
	unsigned categoryIndex = (unsigned)(point.x/questionSize.width);
	
	if( [[mainBoard getQuestion:questionIndex inCategory:categoryIndex] used] )
		return;
	if( delegate && [delegate respondsToSelector:@selector(questionSelected:inCategory:)] )
		[delegate questionSelected:questionIndex inCategory:categoryIndex];
	
}
@end

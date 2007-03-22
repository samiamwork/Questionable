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
		[placeholderMessage setText:@"No game has been started yet."];
		[placeholderMessage setFontSize:frameRect.size.height/5.0f];
		[placeholderMessage setAlignment:kTIPTextAlignmentCenter];
		[placeholderMessage setColor:[NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:0.5f]];
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	if( mainBoard != nil )
		[mainBoard release];
	if( _question != nil )
		[_question release];
	
	[placeholderMessage release];
	[titleArray release];
	[pointArray release];
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

#pragma mark Board Methods

- (void)setBoard:(TriviaBoard *)newBoard
{
	if( newBoard == mainBoard )
		return;
	
	[mainBoard release];
	mainBoard = newBoard;
	
	if( mainBoard != nil )
		[mainBoard retain];
	
	TriviaCategory *thisCategory;
	NSEnumerator *categoryEnumerator = [[mainBoard categories] objectEnumerator];
	
	[titleArray removeAllObjects];
	while( (thisCategory = [categoryEnumerator nextObject]) ) {
		TIPTextContainer *newText = [TIPTextContainer containerWithString:[thisCategory title]];
		[newText setColor:[NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
		
		[titleArray addObject:newText];
		if( [[thisCategory questions] count] > questionsPerCategory )
			questionsPerCategory = [[thisCategory questions] count];
		
	}

	[pointArray removeAllObjects];
	unsigned questionIndex;
	for( questionIndex = 0; questionIndex < questionsPerCategory; questionIndex++ ) {
		TIPTextContainer *newText = [TIPTextContainer containerWithString:[[NSNumber numberWithInt:questionIndex*100+100] stringValue]];
		[newText setFont:[NSFont fontWithName:@"Helvetica-Bold" size:15.0f]];
		[newText setColor:[NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
		
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
	
	CGContextSetLineWidth(currentContext,4.0f);
	CGContextSetRGBStrokeColor(currentContext,0.0f,0.0f,0.0f,0.3f);
	
	CGContextSetLineWidth(currentContext,5.0f);
	unsigned categoryIndex;
	for( categoryIndex = 0; categoryIndex<[[mainBoard categories] count]; categoryIndex++ ) {
		TIPTextContainer *thisText = [titleArray objectAtIndex:categoryIndex];
		
		currentRect.size.height = titleHeight;
		currentRect.origin.y = bounds.size.height - titleHeight;
		
		CGContextSetRGBFillColor(currentContext, 0.5f,0.5f,0.5f,0.1f);
		CGContextFillRect(currentContext,currentRect);
		
		[thisText setFontSize:currentRect.size.height/2.0f];
		[thisText fitTextInRect:NSInsetRect(*(NSRect *)&currentRect, 4.0f, 4.0f)];
		[thisText setColor:[NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:0.9f]];
		//[thisText drawTextInRect:NSMakeRect(currentRect.origin.x+0.5f,currentRect.origin.y-0.5f,currentRect.size.width,currentRect.size.height) inContext:currentContext];
		//[thisText setColor:[NSColor whiteColor]];
		[thisText drawTextInRect:*(NSRect *)&currentRect inContext:currentContext];
		
		CGContextMoveToPoint(currentContext,currentRect.origin.x,currentRect.origin.y);
		CGContextAddLineToPoint(currentContext,currentRect.origin.x+currentRect.size.width,currentRect.origin.y);
		CGContextStrokePath(currentContext);
		
		currentRect.origin.y -= qSize.height;
		currentRect.size.height = qSize.height;
		unsigned questionIndex;
		for( questionIndex = 0; questionIndex<questionsPerCategory; questionIndex++ ) {
			TriviaQuestion *aQuestion = [[[[mainBoard categories] objectAtIndex:categoryIndex] questions] objectAtIndex:questionIndex];
			if( ! [aQuestion used] ) {
				TIPTextContainer *aPointText = [pointArray objectAtIndex:questionIndex];
				[aPointText setFontSize:qSize.height/2.0f];
				[aPointText setColor:[NSColor blackColor]];
				[aPointText drawTextInRect:NSMakeRect(currentRect.origin.x+1.0f,currentRect.origin.y-1.0f,currentRect.size.width,currentRect.size.height) inContext:currentContext];
				[aPointText setColor:[NSColor whiteColor]];
				[aPointText drawTextInRect:*(NSRect *)&currentRect inContext:currentContext];
			}
			
			if( questionIndex != questionsPerCategory-1 ) {
				CGContextMoveToPoint(currentContext,currentRect.origin.x,currentRect.origin.y);
				CGContextAddLineToPoint(currentContext,currentRect.origin.x+currentRect.size.width,currentRect.origin.y);
				CGContextStrokePath(currentContext);
			}
			
			currentRect.origin.y -= qSize.height;
		}
		
		if( categoryIndex != [[mainBoard categories] count]-1 ) {
			CGContextMoveToPoint(currentContext,currentRect.origin.x+currentRect.size.width,bounds.origin.y);
			CGContextAddLineToPoint(currentContext,currentRect.origin.x+currentRect.size.width,bounds.origin.y+bounds.size.height);
			CGContextStrokePath(currentContext);
		}
		
		currentRect.origin.x += qSize.width;
	}
}

- (void)drawString:(NSString *)aString
{
	if( aString == nil )
		return;
	
	NSRect bounds = [self bounds];
	TIPTextContainer *aTextContainer = [[TIPTextContainer alloc] init];
	[aTextContainer setText:aString];
	[aTextContainer setFontSize:bounds.size.height/20.0f];
	
	NSRect textRect = NSInsetRect(bounds,bounds.size.height*0.05f,bounds.size.height*0.05f);
	[aTextContainer fitTextInRect:textRect];
	if( [aTextContainer fontSize] > textRect.size.height/5.0f)
		[aTextContainer setFontSize:textRect.size.height/5.0f];
	[aTextContainer setColor:[NSColor blackColor]];
	//[aTextContainer drawTextInRect:NSMakeRect(bounds.origin.x+1.0f,bounds.origin.y-1.0f,bounds.size.width,bounds.size.height)
	//					 inContext:[[NSGraphicsContext currentContext] graphicsPort]];
	//[aTextContainer setColor:[NSColor whiteColor]];
	[aTextContainer drawTextInRect:bounds
						 inContext:[[NSGraphicsContext currentContext] graphicsPort]];
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
	
	CGContextSetLineWidth(currentContext,4.0f);
	CGContextSetRGBStrokeColor(currentContext,0.0f,0.0f,0.0f,0.3f);
	CGContextStrokeRect(currentContext,*(CGRect *)&bounds);

	switch( _viewState ) {
		case kTriviaSimpleViewBoard:
			[self drawBoard];
			break;
		case kTriviaSimpleViewQuestion:
			[self drawString:(NSString *)[_question question]];
			break;
		case kTriviaSimpleViewAnswer:
			[self drawString:[_question answer]];
			break;
		default:
			CGContextSetRGBFillColor(currentContext,0.2f,0.2f,0.2f,1.0f);
			[placeholderMessage setFontSize:bounds.size.height/8.0f];
			[placeholderMessage setColor:[NSColor blackColor]];
			[placeholderMessage drawTextInRect:NSMakeRect(bounds.origin.x+1.0f,bounds.origin.y-1.0f,bounds.size.width,bounds.size.height) inContext:currentContext];
			[placeholderMessage setColor:[NSColor whiteColor]];
			[placeholderMessage drawTextInRect:bounds inContext:currentContext];
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

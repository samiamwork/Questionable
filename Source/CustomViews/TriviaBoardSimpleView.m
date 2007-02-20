//
//  TriviaBoardSimpleView.m
//  TriviaPlayer
//
//  Created by Nur Monson on 10/19/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaBoardSimpleView.h"

#define TITLEFRACT 0.2f

@interface NSObject (TriviaViewDelegateMethods)
- (void)questionSelected:(unsigned)questionIndex inCategory:(unsigned)categoryIndex;
@end

@implementation TriviaBoardSimpleView

- (id)initWithFrame:(NSRect)frameRect
{
	if( (self = [super initWithFrame:frameRect]) ) {
		enabled = NO;
		
		mainBoard = nil;
		titleArray = [[NSMutableArray alloc] init];
		pointArray = [[NSMutableArray alloc] init];
		usedQuestionsArray = [[NSMutableArray alloc] init];
		numberOfCategories = 0;
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
	
	[placeholderMessage release];
	[titleArray release];
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
	
	[titleArray removeAllObjects];
	[pointArray removeAllObjects];
	[usedQuestionsArray removeAllObjects];
	
	numberOfCategories = [[mainBoard categories] count];
	
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
	
	unsigned questionIndex;
	for( questionIndex = 0; questionIndex < questionsPerCategory; questionIndex++ ) {
		TIPTextContainer *newText = [TIPTextContainer containerWithString:[[NSNumber numberWithInt:questionIndex*100+100] stringValue]];
		[newText setFontWithName:@"Impact"];
		[newText setColor:[NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
		
		[pointArray addObject:newText];
	}
	
	categoryEnumerator = [titleArray objectEnumerator];
	id thisTitle;
	while( (thisTitle = [categoryEnumerator nextObject]) )
		[usedQuestionsArray addObject:[NSMutableArray arrayWithArray:pointArray]];
	
	[self display];
}

- (TriviaBoard *)board
{
	return mainBoard;
}

- (void)enable:(BOOL)enable question:(unsigned)theQuestionIndex inCategory:(unsigned)theCategoryIndex
{
	if( enable ) {
		[[usedQuestionsArray objectAtIndex:theCategoryIndex] replaceObjectAtIndex:theQuestionIndex withObject:[pointArray objectAtIndex:theQuestionIndex]];
	} else {
		[[usedQuestionsArray objectAtIndex:theCategoryIndex] replaceObjectAtIndex:theQuestionIndex withObject:[NSNull null]];
	}
	
	[self setNeedsDisplay:YES];
}

- (void)setEnable:(BOOL)isEnabled;
{
	enabled = isEnabled;
	[self setNeedsDisplay:YES];
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	NSRect bounds = [self bounds];
	
	CGContextRef currentContext = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextClearRect(currentContext, *(CGRect *)&bounds);
	
	if( mainBoard == nil ) {
		CGContextSetRGBFillColor(currentContext,0.2f,0.2f,0.2f,1.0f);
		CGContextFillRect(currentContext, *(CGRect *)&bounds);
		[placeholderMessage setFontSize:bounds.size.height/8.0f];
		[placeholderMessage drawTextInRect:bounds inContext:currentContext];
	} else {
		float titleHeight = bounds.size.height * TITLEFRACT;
		NSSize qSize;
		qSize.height = (bounds.size.height - titleHeight)/questionsPerCategory;
		qSize.width = bounds.size.width/numberOfCategories;
		CGRect currentRect = CGRectMake(0.0f, bounds.size.height-titleHeight, qSize.width, titleHeight);
		
		CGContextSetRGBStrokeColor(currentContext,0.0f,0.0f,0.0f,1.0f);
		unsigned categoryIndex;
		for( categoryIndex = 0; categoryIndex<numberOfCategories; categoryIndex++ ) {
			TIPTextContainer *thisText = [titleArray objectAtIndex:categoryIndex];
			
			currentRect.size.height = titleHeight;
			currentRect.origin.y = bounds.size.height - titleHeight;
			
			CGContextSetRGBFillColor(currentContext, 0.0f,0.0f,0.2f,1.0f);
			CGContextFillRect(currentContext,currentRect);
			CGContextStrokeRect(currentContext,currentRect);
			[thisText setFontSize:currentRect.size.height/5.0f];
			[thisText drawTextInRect:*(NSRect *)&currentRect inContext:currentContext];
			
			currentRect.origin.y -= qSize.height;
			currentRect.size.height = qSize.height;
			unsigned questionIndex;
			//TODO make this get the points to draw from a dictionary matched by point value
			for( questionIndex = 0; questionIndex<questionsPerCategory; questionIndex++ ) {
				TIPTextContainer *thePointText = [[usedQuestionsArray objectAtIndex:categoryIndex] objectAtIndex:questionIndex];
				
				CGContextSetRGBFillColor(currentContext,0.0f,0.0f,0.4f,1.0f);
				CGContextFillRect(currentContext,currentRect);
				CGContextStrokeRect(currentContext,currentRect);
				if( (id)thePointText != (id)[NSNull null] ) {
					[thePointText setFontSize:qSize.height/2.0f];
					[thePointText drawTextInRect:*(NSRect *)&currentRect inContext:currentContext];
				}
				
				currentRect.origin.y -= qSize.height;
				
			}
			currentRect.origin.x += qSize.width;
		}
		
		if( !enabled ) {
			CGContextSetRGBFillColor(currentContext,1.0f,1.0f,1.0f,0.5f);
			CGContextFillRect(currentContext,*(CGRect *)&bounds);
		}
	}
}

#pragma mark mouse tracking

- (void)mouseUp:(NSEvent *)theEvent
{
	if( !enabled )
		return;
	
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSRect bounds = [self bounds];
	
	if( mainBoard == nil )
		return;
	
	if( [self mouse:point inRect:bounds] == NO )
		return;
	
	// stop if it's in the title region
	float clickableHeight = bounds.size.height-(bounds.size.height*TITLEFRACT);
	if( point.y > clickableHeight )
		return;
	
	NSSize questionSize = NSMakeSize(bounds.size.width/numberOfCategories, clickableHeight/questionsPerCategory);
	
	unsigned questionIndex = questionsPerCategory-1-(unsigned)(point.y/questionSize.height);
	unsigned categoryIndex = (unsigned)(point.x/questionSize.width);
	
	if( [[mainBoard getQuestion:questionIndex inCategory:categoryIndex] used] )
		return;
	if( delegate && [delegate respondsToSelector:@selector(questionSelected:inCategory:)] )
		[delegate questionSelected:questionIndex inCategory:categoryIndex];
	
}
@end

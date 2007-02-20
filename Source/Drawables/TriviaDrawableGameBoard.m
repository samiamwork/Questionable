//
//  TriviaDrawableGameBoard.m
//  TriviaPlayer
//
//  Created by Nur Monson on 10/8/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaDrawableGameBoard.h"


@implementation TriviaDrawableGameBoard

- (id)init
{
	if( (self = [super init]) ) {
		
		categoryTitles = [[NSMutableArray alloc] init];
		categoryPoints = [[NSMutableArray alloc] init];
		
		titleContainer = [TIPTextContainer containerWithString:@"title" 
														 color:[NSColor colorWithCalibratedWhite:1.0f alpha:1.0f]
													  fontName:@"HelveticaNeue"];
		[titleContainer retain];
		pointsContainer = [TIPTextContainer containerWithString:@"100"
														  color:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:1.0f]
													   fontName:@"Impact"];
		[pointsContainer retain];
		
		unusedPoints = [[NSArray alloc] initWithObjects:
			[TIPTextContainer containerWithString:@"100" color:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:1.0f] fontName:@"Impact"],
			[TIPTextContainer containerWithString:@"200" color:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:1.0f] fontName:@"Impact"],
			[TIPTextContainer containerWithString:@"300" color:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:1.0f] fontName:@"Impact"],
			[TIPTextContainer containerWithString:@"400" color:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:1.0f] fontName:@"Impact"],
			[TIPTextContainer containerWithString:@"500" color:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:1.0f] fontName:@"Impact"],
			nil];
			
		usedPoints = [[NSArray alloc] initWithObjects:
			[TIPTextContainer containerWithString:@"100" color:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:0.3f] fontName:@"Impact"],
			[TIPTextContainer containerWithString:@"200" color:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:0.3f] fontName:@"Impact"],
			[TIPTextContainer containerWithString:@"300" color:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:0.3f] fontName:@"Impact"],
			[TIPTextContainer containerWithString:@"400" color:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:0.3f] fontName:@"Impact"],
			[TIPTextContainer containerWithString:@"500" color:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:0.3f] fontName:@"Impact"],
			nil];
		availableColor = [[NSColor colorWithCalibratedWhite:0.0f alpha:1.0f] retain];
		disabledColor = [[NSColor colorWithCalibratedWhite:0.0f alpha:0.3f] retain];
		pointsBox = [[TriviaDrawablePointsBox alloc] init];
		titleBox = [[TriviaDrawableCategoryTitleBox alloc] init];
		
		blackShine = TIPGradientBlackShineCreate();
		
		board = nil;
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	if( board ) {
		[board release];
		[categoryTitles release];
		[categoryPoints release];
	}	
	
	[unusedPoints release];
	[usedPoints release];
	
	[pointsBox release];
	[titleBox release];
	
	//[blackShine release];
	TIPGradientRelease(blackShine);
}

- (TriviaBoard *)board
{
	return board;
}
- (void)setBoard:(TriviaBoard *)newBoard
{
	if( newBoard == board )
		return;
	
	[board release];
	board = [newBoard retain];
	
	questionCount = 0;
	NSEnumerator *categoryEnumerator = [[board categories] objectEnumerator];
	TriviaCategory *aCategory;
	while( (aCategory = [categoryEnumerator nextObject]) ) {
		if( [[aCategory questions] count] > questionCount )
			questionCount = [[aCategory questions] count];
	}
}
/*
- (void)enable:(BOOL)enable question:(unsigned)theQuestionIndex inCategory:(unsigned)theCategoryIndex
{
	NSMutableArray *theCategory = [categoryPoints objectAtIndex:theCategoryIndex];
	NSArray *thePoints = usedPoints;
	TIPTextContainer *theContainer;
	
	if( !theCategory ) {
		printf("Category index out of range!\n");
		return;
	}
	
	if( enable )
		thePoints = unusedPoints;
	
	theContainer = [thePoints objectAtIndex:theQuestionIndex];
	if( !theContainer ) {
		printf("Question index out of range!\n");
		return;
	}
	
	[theCategory replaceObjectAtIndex:theQuestionIndex withObject:theContainer];
}
*/
- (void)drawBackgroundInRect:(NSRect)theRect inContext:(CGContextRef)theContext
{
	CGContextSetRGBFillColor(theContext, 0.0f, 0.0f, 0.0f, 1.0f);
	CGContextFillRect(theContext, *(CGRect *)&theRect);
}

- (void)drawInRect:(NSRect)theRect inContext:(CGContextRef)theContext
{
	CGContextSaveGState( theContext );
	
	[self drawBackgroundInRect:theRect inContext:theContext];
	if( !board ) {
		// draw text indicating no board has been set
		return;
	}
	
	NSSize titleSize;
	NSSize pointsBoxSize;
	float margins = theRect.size.height * 0.1f;
	float topMargin = margins*0.25f;
	NSRect currentRect;
	
	NSArray *categories = [board categories];

	float categoryCount = (float)[categories count];
	titleSize.width = (theRect.size.width-margins*2.0f)/categoryCount;
	titleSize.height = (theRect.size.height-margins-topMargin)*0.15;
	[titleBox makeLayerForSize:titleSize withContext:theContext];
	
	pointsBoxSize.width = titleSize.width;
	pointsBoxSize.height = (theRect.size.height-margins-topMargin-titleSize.height)/(float)questionCount;
	[pointsBox makeLayerForSize:pointsBoxSize withContext:theContext];
	
	currentRect.origin.x = margins;
	currentRect.size.width = titleSize.width;
	
	[pointsContainer setFontSize:pointsBoxSize.height/2.0f];
	
	NSRect titleTextRect;
	
	//TODO: I shouldn't have to match calculations in the category title Drawable
	titleTextRect.size = titleSize;
	titleTextRect.size.width -= (titleSize.width*0.2f) + 10.0f;
	titleTextRect.size.height -= 10.0f;
	titleTextRect.origin.x = margins + currentRect.size.width*0.1f+5.0f;
	titleTextRect.origin.y = theRect.size.height-titleSize.height-topMargin + 5.0f;
	
	[titleContainer setFontSize:titleTextRect.size.height/4.0f];
	
	NSEnumerator *categoryEnumerator = [categories objectEnumerator];
	TriviaCategory *aCategory;
	
	while( (aCategory = [categoryEnumerator nextObject]) ) {
		
		currentRect.size.height = titleSize.height;
		currentRect.origin.y = theRect.size.height-titleSize.height-topMargin;
		
		CGContextDrawLayerAtPoint( theContext, *(CGPoint *)&currentRect.origin, [titleBox getLayer]);
		
		[titleContainer setText:[aCategory title]];
		[titleContainer drawTextInRect:titleTextRect inContext:theContext];
		currentRect.origin.y -= pointsBoxSize.height;
		currentRect.size.height = pointsBoxSize.height;
		
		unsigned questionIndex;
		for( questionIndex = 0; questionIndex < [[aCategory questions] count]; questionIndex++ ) {
			TriviaQuestion *aQuestion = [[aCategory questions] objectAtIndex:questionIndex];
			CGContextDrawLayerAtPoint( theContext, *(CGPoint *)&currentRect.origin, [pointsBox getLayer]);
			[pointsContainer setText:[NSString stringWithFormat:@"%d",(questionIndex+1)*100]];
			
			if( [aQuestion used] )
				[pointsContainer setColor:disabledColor];
			else
				[pointsContainer setColor:availableColor];
			[pointsContainer drawTextInRect:currentRect inContext:theContext];
			currentRect.origin.y -= pointsBoxSize.height;
		}
		
		// draw half of the bottom question Boxes flipped
		CGContextSaveGState(theContext);
		//TODO: use actual flipping of CTM to draw flipped box
		//CGContextScaleCTM(theContext, 1.0f, -1.0f);
		CGRect clippingRect = CGRectMake(currentRect.origin.x,0.0f,currentRect.size.width,currentRect.origin.y+pointsBoxSize.height);
		CGContextClipToRect(theContext, clippingRect);
		currentRect.origin.y -= pointsBoxSize.height*0.05f;
		CGContextDrawLayerAtPoint( theContext, CGPointMake(currentRect.origin.x,currentRect.origin.y),[pointsBox getLayer]);
		//[blackShine fillRect:*(NSRect *)&clippingRect angle:90.0f withContext:theContext];
		TIPGradientAxialFillRect(theContext,blackShine,*(CGRect *)&clippingRect,90.0f);
		CGContextRestoreGState( theContext );
		
		currentRect.origin.x += titleSize.width;
		titleTextRect.origin.x += titleSize.width;
	}
	
	CGContextRestoreGState( theContext );
}

@end

//
//  ButtonTextCell.m
//  TriviaOutlineView
//
//  Created by Nur Monson on 1/19/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "ButtonTextCell.h"


@implementation ButtonTextCell

- (id)init
{
	if( (self = [super init]) ) {
		buttonCell = [[NSButtonCell alloc] init];
		[buttonCell setImage:[NSImage imageNamed:@"plus"]];
		[buttonCell setImagePosition:NSImageOnly];
		[buttonCell setBezeled:NO];
		[buttonCell setBordered:NO];
	}

	return self;
}

- (void)dealloc
{
	[buttonCell release];

	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	ButtonTextCell *newCell = (ButtonTextCell *)[super copyWithZone:zone];
	newCell->buttonCell = [buttonCell retain];
	
	return newCell;
}

- (void)setTarget:(id)target
{
	[buttonCell setTarget:target];
}
- (void)setAction:(SEL)selector
{
	[buttonCell setAction:selector];
}

#pragma mark Accessor Methods

- (NSButtonCell *)buttonCell
{
	return buttonCell;
}
- (void)setButtonCell:(NSButtonCell *)newButtonCell
{
	if( newButtonCell == buttonCell )
		return;
	
	[buttonCell release];
	buttonCell = [newButtonCell retain];
}

#pragma mark Utility Methods

- (NSDictionary *)preferredTextStyleForControl:(NSView *)controlView
{
	NSMutableParagraphStyle *paragraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	[paragraphStyle setTighteningFactorForTruncation:-0.05f];
	NSColor *textColor = [self isHighlighted] && (controlView == [[controlView window] firstResponder]) ? [NSColor whiteColor] : [NSColor blackColor];
	
	NSDictionary *style;
	if( [[self objectValue] isKindOfClass:[TriviaQuestion class]] && (![[(TriviaQuestion *)[self objectValue] question] isKindOfClass:[NSString class]] || [(NSString *)[(TriviaQuestion *)[self objectValue] question] length] == 0) )
		style = [NSDictionary dictionaryWithObjectsAndKeys:paragraphStyle, NSParagraphStyleAttributeName, [super font], NSFontAttributeName, textColor, NSForegroundColorAttributeName, [NSNumber numberWithFloat:0.5f], NSObliquenessAttributeName, nil];
	else
		style = [NSDictionary dictionaryWithObjectsAndKeys:paragraphStyle, NSParagraphStyleAttributeName, [super font], NSFontAttributeName, textColor, NSForegroundColorAttributeName, nil];
	
	return style;
}

- (void)divideCellFrame:(NSRect)cellFrame intoTextRect:(NSRect *)textRect andImageRect:(NSRect *)imageRect usingStyle:(NSDictionary *)aStyle
{
	float buttonWidth = cellFrame.size.height;
	NSSize textSize = [[[self objectValue] description] sizeWithAttributes:aStyle];
	textSize.width = ceilf(textSize.width) + 8.0f;
	
	if( textSize.width >= cellFrame.size.width - buttonWidth ) {
		NSDivideRect(cellFrame, imageRect, textRect,buttonWidth,NSMaxXEdge);
	} else {
		*textRect = *imageRect = cellFrame;
		textRect->size.width = textSize.width;
		imageRect->origin.x += textSize.width;
		imageRect->size.width = buttonWidth;
	}
}

- (BOOL)hasButton
{
	id objectValue = [self objectValue];
	if( [objectValue isKindOfClass:[TriviaBoard class]] && [(TriviaBoard *)objectValue isFull] )
		return NO;

	if( [objectValue isKindOfClass:[TriviaCategory class]] && [(TriviaCategory *)objectValue isFull] )
		return NO;
	
	if( ![[self objectValue] isKindOfClass:[TriviaBoard class]] && ![[self objectValue] isKindOfClass:[TriviaCategory class]] )
		return NO;
	
	return YES;
}

#pragma mark Mouse Tracking

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
	if( ![self hasButton] )
		return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:untilMouseUp];
	
	NSRect textRect;
	NSRect buttonRect;
	[self divideCellFrame:cellFrame intoTextRect:&textRect andImageRect:&buttonRect usingStyle:[self preferredTextStyleForControl:controlView]];
	
	NSPoint mouseLocation = [controlView convertPoint:[theEvent locationInWindow] fromView:nil];
	if( NSPointInRect(mouseLocation, buttonRect) )
		return [buttonCell trackMouse:theEvent inRect:buttonRect ofView:controlView untilMouseUp:untilMouseUp];

	return [super trackMouse:theEvent inRect:textRect ofView:controlView untilMouseUp:untilMouseUp];
}
/*
- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
	//printf("startTrackingAt: (%.03f, %.03f)\n", startPoint.x, startPoint.y);
	return [super startTrackingAt:startPoint inView:controlView];
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{
	//printf("continueTracking: (%.03f, %.03f) -> (%.03f, %.03f)\n", lastPoint.x, lastPoint.y, currentPoint.x, currentPoint.y);
	return [super continueTracking:lastPoint at:currentPoint inView:controlView];
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
	//printf("stopTracking: (%.03f, %.03f) -> (%.03f, %.03f)\n", lastPoint.x, lastPoint.y, stopPoint.x, stopPoint.y);
	[super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
}
*/
#pragma mark Editing

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{
	[super editWithFrame:aRect inView:controlView editor:textObj delegate:anObject event:theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(int)selStart length:(int)selLength
{
	[super selectWithFrame:aRect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

#pragma mark Drawing

- (NSSize)cellSize {
	return [super cellSize];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSRect textRect = cellFrame;
	NSRect buttonRect;
	NSString *stringValue = [[self objectValue] description];
	NSDictionary *style = [self preferredTextStyleForControl:controlView];
	
	if( [self hasButton] ) {
		[self divideCellFrame:cellFrame intoTextRect:&textRect andImageRect:&buttonRect usingStyle:style];
		buttonRect = NSInsetRect(buttonRect,0.0f,1.0f);
		[buttonCell drawWithFrame:buttonRect inView:controlView];
	}

	NSSize textSize = [stringValue sizeWithAttributes:style];
	
	float dy = (textRect.size.height - textSize.height)/2.0f;
	NSRect insetRect = NSInsetRect(textRect,4.0f,dy);
	[stringValue drawInRect:insetRect withAttributes:style];
}

@end

//
//  TIPSideGradientTableView.m
//  TriviaPlayer
//
//  Created by Nur Monson on 3/30/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TIPSideGradientTableView.h"
#include "TIPGradient.h"

// Row gradient color hilighting by Wil Shipley

@interface TIPSideGradientTableView (Private)
- (void)_windowDidChangeKeyNotification:(NSNotification *)notification;
@end

@implementation TIPSideGradientTableView

#pragma mark NSObject

- (void)dealloc;
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

#pragma mark NSView

- (void)viewWillMoveToWindow:(NSWindow *)newWindow;
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSWindowDidResignKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_windowDidChangeKeyNotification:)
												 name:NSWindowDidResignKeyNotification object:newWindow];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSWindowDidBecomeKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_windowDidChangeKeyNotification:)
												 name:NSWindowDidBecomeKeyNotification object:newWindow];
}

#pragma mark NSTableView

- (void)highlightSelectionInClipRect:(NSRect)rect;
{
	// Take the color apart
	NSColor *alternateSelectedControlColor = [NSColor colorWithCalibratedWhite:0.5f alpha:1.0f];//[NSColor alternateSelectedControlColor];
	CGFloat hue, saturation, brightness, alpha;
	[[alternateSelectedControlColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
	
	// Create synthetic darker and lighter versions
	NSColor *lighterColor = [NSColor colorWithDeviceHue:hue saturation:MAX(0.0, saturation-.12) brightness:MIN(1.0,	brightness+0.30) alpha:alpha];
	NSColor *darkerColor = [NSColor colorWithDeviceHue:hue saturation:MIN(1.0, (saturation > .04) ? saturation+0.12 : 0.0) brightness:MAX(0.0, brightness-0.045) alpha:alpha];
	
	// If this view isn't key, use the gray version of the dark color.
	// Note that this varies from the standard gray version that NSCell
	// returns as its highlightColorWithFrame: when the cell is not in a
	// key view, in that this is a lot darker. Mike and I think this is
	// justified for this kind of view -- if you're using the dark
	// selection color to show the selected status, it makes sense to
	// leave it dark.
	/*
	NSResponder *firstResponder = [[self window] firstResponder];
	if (![firstResponder isKindOfClass:[NSView class]] || ![(NSView *)firstResponder isDescendantOf:self] || ![[self window] isKeyWindow]) {
		alternateSelectedControlColor = [[alternateSelectedControlColor colorUsingColorSpaceName:NSDeviceWhiteColorSpace] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		lighterColor = [[lighterColor colorUsingColorSpaceName:NSDeviceWhiteColorSpace] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		darkerColor = [[darkerColor colorUsingColorSpaceName:NSDeviceWhiteColorSpace] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	}
	*/
	// Set up the helper function for drawing washes
	// CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	// _twoColorsType *twoColors = malloc(sizeof(_twoColorsType)); // We
	// malloc() the helper data because we may draw this wash during
	// printing, in which case it won't necessarily be evaluated
	// immediately. We need for all the data the shading function needs
	// to draw to potentially outlive us.
	TIPMutableGradientRef gradient = TIPMutableGradientCreate();
	CGFloat red, green, blue;
	[lighterColor getRed:&red green:&green blue:&blue alpha:&alpha];
	TIPGradientAddRGBColorStop(gradient,0.0f,red,green,blue,alpha);
	
	[darkerColor getRed:&red green:&green blue:&blue alpha:&alpha];
	TIPGradientAddRGBColorStop(gradient,1.0f,red,green,blue,alpha);
	
	NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
	NSUInteger rowIndex = [selectedRowIndexes indexGreaterThanOrEqualToIndex:0];
	
	while (rowIndex != NSNotFound) {
		unsigned int endOfCurrentRunRowIndex, newRowIndex = rowIndex;
		do {
			endOfCurrentRunRowIndex = newRowIndex;
			newRowIndex = [selectedRowIndexes indexGreaterThanIndex:endOfCurrentRunRowIndex];
		} while (newRowIndex == endOfCurrentRunRowIndex + 1);
		
		NSRect rowRect = NSUnionRect([self rectOfRow:rowIndex], [self rectOfRow:endOfCurrentRunRowIndex]);
		
		NSRect topBar, bottomRect;
		NSDivideRect(rowRect, &topBar, &bottomRect, 2.0, NSMinYEdge);
		NSRect bottomBar, washRect;
		NSDivideRect(bottomRect, &bottomBar, &washRect, 1.0, NSMaxYEdge);
		// Draw the top line of pixels of the selected row in the alternateSelectedControlColor
		[alternateSelectedControlColor set];
		NSRectFill(topBar);
		NSRectFill(bottomBar);
		
		// Draw a soft wash underneath it
		CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
		CGContextSaveGState(context);
			TIPGradientAxialFillRect(context,gradient,(CGRect){{NSMinX(washRect),NSMinY(washRect)}, {NSWidth(washRect),NSHeight(washRect)}},0.0f);
		CGContextRestoreGState(context);
		
		rowIndex = newRowIndex;
	}

}

- (void)selectRow:(NSInteger)row byExtendingSelection:(BOOL)willExtend;
{
	// we display extra because we draw
	// multiple contiguous selected rows differently, so changing
	//	one row's selection can change how others draw.
	[super selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:willExtend];
	[self setNeedsDisplay:YES];
}

- (void)selectRowIndexes:(NSIndexSet *)indexes byExtendingSelection:(BOOL)willExtend
{
	// we display extra because we draw
	// multiple contiguous selected rows differently, so changing
	//	one row's selection can change how others draw.
	[super selectRowIndexes:indexes byExtendingSelection:willExtend];
	[self setNeedsDisplay:YES];
}

- (void)deselectRow:(NSInteger)row;
{
	// we display extra because we draw
	// multiple contiguous selected rows differently, so changing
	// one row's selection can change how others draw.
	[super deselectRow:row];
	[self setNeedsDisplay:YES];
}

#pragma mark NSTableView (Private)

- (id)_highlightColorForCell:(NSCell *)cell;
{
	return nil;
}

@end


@implementation TIPSideGradientTableView (Private)

- (void)_windowDidChangeKeyNotification:(NSNotification
										 *)notification;
{
	[self setNeedsDisplay:YES];
}

@end


//
//  RSDragDelegationView.m
//  RSAppKit
//
//  Created by Daniel Jalkut on 6/7/06.
//  Copyright 2006 Red Sweater Software. All rights reserved.
//

#import "TextDragView.h"

@implementation TextDragView

//  draggingDelegate 
- (id) draggingDelegate
{
    return mDraggingDelegate; 
}

- (void) setDraggingDelegate: (id) theDraggingDelegate
{
	// DO NOT RETAIN
	mDraggingDelegate = theDraggingDelegate;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if (mDraggingDelegate && [mDraggingDelegate respondsToSelector:@selector(draggingEntered:)])
		return [mDraggingDelegate draggingEntered:sender];
	else
		return [super draggingEntered:sender];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    if (mDraggingDelegate && [mDraggingDelegate respondsToSelector:@selector(draggingUpdated:)])
		return [mDraggingDelegate draggingUpdated:sender];
	else
		return [super draggingUpdated:sender];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    if (mDraggingDelegate && [mDraggingDelegate respondsToSelector:@selector(draggingExited:)])
		[mDraggingDelegate draggingExited:sender];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    if (mDraggingDelegate && [mDraggingDelegate respondsToSelector:@selector(prepareForDragOperation:)])
		return [mDraggingDelegate prepareForDragOperation:sender];
	else
		return [super prepareForDragOperation:sender];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    if (mDraggingDelegate && [mDraggingDelegate respondsToSelector:@selector(performDragOperation:)])
		return [mDraggingDelegate performDragOperation:sender];
	else
		return [super performDragOperation:sender];
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    if (mDraggingDelegate && [mDraggingDelegate respondsToSelector:@selector(concludeDragOperation:)])
		[mDraggingDelegate concludeDragOperation:sender];
}

@end

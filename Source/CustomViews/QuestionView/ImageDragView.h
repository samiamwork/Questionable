//
//  RSDragDelegationView.h
//
//  Created by Daniel Jalkut on 6/7/06.
//  Copyright 2006 Red Sweater Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ImageDragView : NSImageView
{
	// This simple NSView subclass simply forwards all drag messages
	// to a delegate, the same way NSWindow does for its delegate.
	// This facilitates the use (abuse?) of a *large swatch* of the UI
	// as a dragging destination for the client, without having access
	// to or taking over the entire window content.
	id	mDraggingDelegate;	// NOT RETAINED!
}

- (id) draggingDelegate;
- (void) setDraggingDelegate: (id) theDraggingDelegate;

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender;
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender;
- (void)draggingExited:(id <NSDraggingInfo>)sender;
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender;

@end

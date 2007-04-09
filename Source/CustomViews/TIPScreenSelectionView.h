//
//  TIPScreenSelectionView.h
//  TIPScreenSelectionView
//
//  Created by Nur Monson on 9/18/06.
//  Copyright theidiotproject 2006 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TIPGradient.h"

@interface TIPScreenSelectionView : NSView
{
	IBOutlet id delegate;
	NSImage *image;
	
	NSScreen *selectedScreen;
	NSArray *allScreens;
	
	NSAffineTransform *screenToView;
	NSRect totalBounds;
}

- (BOOL)getScreenConfiguration;
- (void)createTransformMatrix:(CGContextRef)cxt;
- (void)screenParametersChanged;
- (NSScreen *)getSelectedScreen;
- (void)setSelectedScreen:(NSScreen *)aScreen;
- (NSRect)transformRect:(NSRect)rect withTransform:(NSAffineTransform*)trans;
- (void)mouseDown:(NSEvent *)theEvent;

- (id)delegate;
- (void)setDelegate:(id)mDelegate;

- (NSImage *)image;
- (void)setImage:(NSImage *)anImage;
@end

@interface NSObject (TIPScreenDelegateMethods)
- (void)selectedScreenChanged:(NSScreen *)selectedScreen;
@end

//
//  FullscreenSheetController.h
//  TriviaPlayer
//
//  Created by Nur Monson on 11/3/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TIPScreenSelectionView.h"

@interface FullscreenSheetController : NSObject {
	id delegate;
	NSWindow *attachedWindow;
	
	IBOutlet TIPScreenSelectionView *screenSelectionView;
	IBOutlet NSWindow *fullscreenSheet;
	
	BOOL fullscreen;
	NSRect lastFrame;
}

- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)setAttachedWindow:(NSWindow *)newWindow;
- (NSWindow *)attachedWindow;

- (void)toggleFullscreen;
- (BOOL)fullscreen;

- (IBAction)cancel:(id)sender;
- (IBAction)setFullscreen:(id)sender;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end

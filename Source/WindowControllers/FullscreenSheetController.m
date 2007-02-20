//
//  FullscreenSheetController.m
//  TriviaPlayer
//
//  Created by Nur Monson on 11/3/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "FullscreenSheetController.h"

@interface NSObject (FullscreenSheetControllerDelegateMethods)
- (void)screenSelected:(NSScreen *)selectedScreen;
@end

@implementation FullscreenSheetController

- (id)init
{
	if( (self = [super init]) ) {
		delegate = nil;
		attachedWindow = nil;
		
		fullscreen = NO;
	}
	
	return self;
}

- (void)setDelegate:(id)aDelegate
{
	if( aDelegate != delegate )
		return;
	
	delegate = aDelegate;
}
- (id)delegate
{
	return delegate;
}

- (void)setAttachedWindow:(NSWindow *)newWindow
{
	// cannot change the attached window if we're fullscreen
	// we're still managing it.
	if( newWindow == attachedWindow  || fullscreen )
		return;
	
	attachedWindow = newWindow;
}
- (NSWindow *)attachedWindow
{
	return attachedWindow;
}

- (BOOL)fullscreen
{
	return fullscreen;
}

- (void)toggleFullscreen
{
	if( !attachedWindow )
		return;
	
	if( fullscreen ) {
		[attachedWindow setFrame:lastFrame display:YES animate:YES];
		fullscreen = NO;
		return;
	}
	
	// "fullscreenSheet" gets connected when the sheet is run
	if( !fullscreenSheet )
		[NSBundle loadNibNamed:@"FullscreenSheet" owner:self];
	
	[NSApp beginSheet:fullscreenSheet
	   modalForWindow:attachedWindow
		modalDelegate:self
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		  contextInfo:nil];
}

- (IBAction)cancel:(id)sender
{
	[NSApp endSheet:fullscreenSheet returnCode:NSCancelButton];
}
- (IBAction)setFullscreen:(id)sender
{
	[NSApp endSheet:fullscreenSheet returnCode:NSOKButton];
}
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if( returnCode == NSCancelButton ) {
		[fullscreenSheet orderOut:self];
		
		//TODO: should check if delegate responds to that message
		if( delegate )
			[delegate screenSelected:nil];
		return;
	}
	
	NSScreen *selectedScreen = [screenSelectionView getSelectedScreen];
	[fullscreenSheet orderOut:self];
	
	lastFrame = [attachedWindow frame];
	fullscreen = YES;
	
	[attachedWindow setFrame:[attachedWindow frameRectForContentRect:[selectedScreen frame]] display:YES animate:YES];
	if( delegate )
		[delegate screenSelected:selectedScreen];
}
@end

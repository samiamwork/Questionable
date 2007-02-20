//
//  SaveProgressController.m
//  TriviaOutlineView
//
//  Created by Nur Monson on 2/6/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "SaveProgressController.h"

@interface NSObject (cancelDelegate)
- (void)saveCanceled;
@end

@implementation SaveProgressController

- (id)init
{
	if( (self = [super initWithWindowNibName:@"SaveProgress"]) ) {
		theMaxBytes = 100;
	}

	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (id)cancelDelegate
{
	return theCancelDelegate;
}
- (void)setCancelDelegate:(id)newCancelDelegate
{
	theCancelDelegate = newCancelDelegate;
}

- (void)beginModalStatus
{
	if( [self window] == nil )
		[NSBundle loadNibNamed:@"SaveProgress" owner:self];
	
	[theProgressBar setIndeterminate:YES];
	[theProgressBar startAnimation:self];
	[theProgressBar setMinValue:0.0];
	[theProgressBar setMaxValue:(double)theMaxBytes];
	[theProgressBar setDoubleValue:0.0];

	[NSApp runModalForWindow:[self window]];
}

- (void)endModalStatus
{
	[[self window] orderOut:nil];

	[NSApp abortModal];
}

- (void)setMaxBytes:(unsigned long long)newMaxBytes
{
	theMaxBytes = newMaxBytes;
	
	if( theProgressBar != nil )
		[theProgressBar setMaxValue:(double)theMaxBytes];
}

- (void)setBytesDone:(unsigned long long)newBytesDone
{
	double currentProgressValue = [theProgressBar doubleValue];
	double newProgressValue = (double)newBytesDone;
	
	[theProgressBar incrementBy:newProgressValue - currentProgressValue];
	[theStatusTextField setStringValue:[NSString stringWithFormat:@"%.01f MB of %.01f MB", (float)(newBytesDone >> 10)/1024.0f, (float)(theMaxBytes >> 10)/1024.0f]];
	
	if( currentProgressValue == 0.0 && newProgressValue != 0.0 )
		[theProgressBar setIndeterminate:NO];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if( returnCode != NSCancelButton )
		return;
	
	return;
}	

- (IBAction)cancelFileCopy:(id)sender
{	
	if( theCancelDelegate != nil && [theCancelDelegate respondsToSelector:@selector(saveCanceled)] )
		[theCancelDelegate saveCanceled];
}

@end

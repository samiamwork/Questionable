//
//  SaveProgressController.h
//  TriviaOutlineView
//
//  Created by Nur Monson on 2/6/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SaveProgressController : NSWindowController {
	IBOutlet NSProgressIndicator *theProgressBar;
	IBOutlet NSTextField *theStatusTextField;
	
	unsigned long long theMaxBytes;
	
	id theCancelDelegate;
}

- (id)cancelDelegate;
- (void)setCancelDelegate:(id)newCancelDelegate;

- (void)endModalStatus;
- (void)beginModalStatus;

- (void)setMaxBytes:(unsigned long long)newMaxBytes;
- (void)setBytesDone:(unsigned long long)newBytesDone;

- (IBAction)cancelFileCopy:(id)sender;
@end

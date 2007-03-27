//
//  TriviaPlayerGetInputController.h
//  Questionable
//
//  Created by Nur Monson on 3/26/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TriviaPlayerGetInputController : NSWindowController {
	IBOutlet NSTextField *_promptField;
	IBOutlet NSProgressIndicator *_spinner;
	
	NSString *_promptString;
}

- (void)setPromptStringForPlayerName:(NSString *)playerName;

- (void)beginModalStatus;
- (void)endModalStatus;
@end

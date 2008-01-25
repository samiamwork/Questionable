//
//  Preferences.h
//  NibTest
//
//  Created by Nur Monson on 4/11/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Preferences : NSObject {
	IBOutlet NSWindow *prefWindow;
	
	IBOutlet NSPopUpButton *gameStartPopUp;
	IBOutlet NSPopUpButton *gameEndPopUp;
	IBOutlet NSPopUpButton *timeUpPopUp;
	IBOutlet NSPopUpButton *buzzInPopUp;
	IBOutlet NSPopUpButton *correctAnswerPopUp;
	IBOutlet NSPopUpButton *incorrectAnswerPopUp;
	
	NSArray *_availableSounds;
}

- (IBAction)showPanel:(id)sender;

- (IBAction)gameStartSoundSelected:(id)sender;
- (IBAction)gameEndSoundSelected:(id)sender;
- (IBAction)timeUpSoundSelected:(id)sender;
- (IBAction)buzzInSoundSelected:(id)sender;
- (IBAction)correctAnswerSoundSelected:(id)sender;
- (IBAction)incorrectAnswerSoundSelected:(id)sender;

@end

//
//  Preferences.m
//  NibTest
//
//  Created by Nur Monson on 4/11/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "Preferences.h"
#import "TriviaSoundController.h"


@implementation Preferences

- (IBAction)showPanel:(id)sender
{
	if(!prefWindow) {
		if(![NSBundle loadNibNamed:@"Preferences" owner:self])  {
			NSLog(@"Failed to load Preferences.nib");
			NSBeep();
			return;
		}
		[prefWindow setHidesOnDeactivate:NO];
		[prefWindow setExcludedFromWindowsMenu:YES];
		[prefWindow setMenu:nil];

		[prefWindow center];
    }
    [prefWindow makeKeyAndOrderFront:nil];
}

- (void)awakeFromNib
{
	if( !prefWindow )
		return;
	
	// Fill up all the Popup menu's with the available sounds and select the one that's selected in each.
	TriviaSoundController *soundController = [TriviaSoundController defaultController];
	
	NSArray *availableSounds = [soundController availableSounds];
	NSEnumerator *soundEnumerator = [availableSounds objectEnumerator];
	NSString *sound;
	NSMenu *soundMenu = [[NSMenu alloc] init];
	while( (sound = [soundEnumerator nextObject]) ) {
		[soundMenu addItemWithTitle:sound action:NULL keyEquivalent:@""];
	}
	
	NSString *soundName;
	[gameStartPopUp setMenu:[[soundMenu copyWithZone:NULL] autorelease]];
	soundName = [soundController getSoundNameForSound:SoundThemeSoundGameStart];
	[gameStartPopUp selectItemWithTitle: soundName ? soundName : @"" ];
	
	[gameEndPopUp setMenu:[[soundMenu copyWithZone:NULL] autorelease]];
	soundName = [soundController getSoundNameForSound:SoundThemeSoundGameEnd];
	[gameEndPopUp selectItemWithTitle: soundName ? soundName : @"" ];
	
	[buzzInPopUp setMenu:[[soundMenu copyWithZone:NULL] autorelease]];
	soundName = [soundController getSoundNameForSound:SoundThemeSoundBuzzIn];
	[buzzInPopUp selectItemWithTitle: soundName ? soundName : @"" ];
	
	[timeUpPopUp setMenu:[[soundMenu copyWithZone:NULL] autorelease]];
	soundName = [soundController getSoundNameForSound:SoundThemeSoundTimeUp];
	[timeUpPopUp selectItemWithTitle: soundName ? soundName : @"" ];
	
	[correctAnswerPopUp setMenu:[[soundMenu copyWithZone:NULL] autorelease]];
	soundName = [soundController getSoundNameForSound:SoundThemeSoundCorrectAnswer];
	[correctAnswerPopUp selectItemWithTitle: soundName ? soundName : @"" ];
	
	[incorrectAnswerPopUp setMenu:[[soundMenu copyWithZone:NULL] autorelease]];
	soundName = [soundController getSoundNameForSound:SoundThemeSoundIncorrectAnswer];
	[incorrectAnswerPopUp selectItemWithTitle: soundName ? soundName : @"" ];
	
	[soundMenu release];
}

- (void)setSound:(NSString *)soundName fromPopUp:(NSPopUpButton *)popUp
{
	TriviaSoundController *soundController = [TriviaSoundController defaultController];
	NSString *soundFile = [[popUp selectedItem] title];
	[soundController setSound:soundName toSoundFileNamed:soundFile];
	[popUp selectItemWithTitle:[soundController getSoundNameForSound:soundName]];
	
	[[TriviaSoundController defaultController] playSound:soundName];
}
- (IBAction)gameStartSoundSelected:(id)sender
{
	[self setSound:SoundThemeSoundGameStart fromPopUp:sender];
}
- (IBAction)gameEndSoundSelected:(id)sender
{
	[self setSound:SoundThemeSoundGameEnd fromPopUp:sender];
}
- (IBAction)timeUpSoundSelected:(id)sender
{
	[self setSound:SoundThemeSoundTimeUp fromPopUp:sender];
}
- (IBAction)buzzInSoundSelected:(id)sender
{
	[self setSound:SoundThemeSoundBuzzIn fromPopUp:sender];
}
- (IBAction)correctAnswerSoundSelected:(id)sender
{
	[self setSound:SoundThemeSoundCorrectAnswer fromPopUp:sender];
}
- (IBAction)incorrectAnswerSoundSelected:(id)sender
{
	[self setSound:SoundThemeSoundIncorrectAnswer fromPopUp:sender];
}

@end

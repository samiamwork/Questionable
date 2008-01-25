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
	_availableSounds = nil;
}

- (void)setPopUp:(NSPopUpButton *)popUp withMenuToCopy:(NSMenu *)theMenu forSoundNamed:(NSString *)soundName
{
	[popUp setMenu:[[theMenu copyWithZone:NULL] autorelease]];
	NSString *soundFile = [[TriviaSoundController defaultController] getSoundNameForSound:soundName];
	[popUp selectItemWithTitle: soundFile ? soundFile : @"" ];
}

- (void)fillPopUps
{
	// Fill up all the Popup menu's with the available sounds and select the one that's selected in each.
	TriviaSoundController *soundController = [TriviaSoundController defaultController];
	
	NSArray *newAvailableSounds = [soundController availableSounds];
	[_availableSounds release];
	_availableSounds = [newAvailableSounds retain];
	NSEnumerator *soundEnumerator = [_availableSounds objectEnumerator];
	NSString *sound;
	NSMenu *soundMenu = [[NSMenu alloc] init];
	while( (sound = [soundEnumerator nextObject]) )
		[soundMenu addItemWithTitle:sound action:NULL keyEquivalent:@""];

	[self setPopUp:gameStartPopUp withMenuToCopy:soundMenu forSoundNamed:SoundThemeSoundGameStart];
	[self setPopUp:gameEndPopUp withMenuToCopy:soundMenu forSoundNamed:SoundThemeSoundGameEnd];
	[self setPopUp:timeUpPopUp withMenuToCopy:soundMenu forSoundNamed:SoundThemeSoundTimeUp];
	[self setPopUp:buzzInPopUp withMenuToCopy:soundMenu forSoundNamed:SoundThemeSoundBuzzIn];
	[self setPopUp:correctAnswerPopUp withMenuToCopy:soundMenu forSoundNamed:SoundThemeSoundCorrectAnswer];
	[self setPopUp:incorrectAnswerPopUp withMenuToCopy:soundMenu forSoundNamed:SoundThemeSoundIncorrectAnswer];
	
	[soundMenu release];
	
}

- (void)awakeFromNib
{
	if( !prefWindow )
		return;
	[self fillPopUps];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
	[self fillPopUps];
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

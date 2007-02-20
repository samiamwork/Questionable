//
//  TriviaSoundController.h
//  TriviaPlayer
//
//  Created by Nur Monson on 11/8/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *SoundThemeSoundGameStart;
extern NSString *SoundThemeSoundGameEnd;
extern NSString *SoundThemeSoundRoundStart;
extern NSString *SoundThemeSoundRoundEnd;
extern NSString *SoundThemeSoundBuzzIn;
extern NSString *SoundThemeSoundCorrectAnswer;
extern NSString *SoundThemeSoundIncorrectAnswer;
extern NSString *SoundThemeSoundTimeUp;

extern NSString *SoundThemeNameDefault;


// shared singleton object

@interface TriviaSoundController : NSObject {
	//TODO: loading them this way does not allow more than one theme loaded at once
	// this will not work well with a document system
	
	// etc.
	BOOL mute;
	// dictionary of dictionaries containing available themes
	NSMutableDictionary *themes;
	NSMutableDictionary *selectedTheme;
	// for later adding the ability to construct your own themes
	NSMutableArray *availableSounds;
	
	// the names of the sounds
	NSArray *soundNames;
}

+ (TriviaSoundController *)defaultController;

- (BOOL)mute;
- (void)setMute:(BOOL)willMute;

- (NSArray *)themes;

- (void)setSelectedTheme:(NSString *)aThemeName;
- (NSString *)selectedTheme;

-  (void)playSound:(NSString *)soundName;
@end

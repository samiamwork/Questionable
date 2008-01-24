//
//  TriviaSoundController.h
//  TriviaPlayer
//
//  Created by Nur Monson on 11/8/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* const SoundThemeSoundGameStart;
extern NSString* const SoundThemeSoundGameEnd;
extern NSString* const SoundThemeSoundRoundStart;
extern NSString* const SoundThemeSoundRoundEnd;
extern NSString* const SoundThemeSoundBuzzIn;
extern NSString* const SoundThemeSoundCorrectAnswer;
extern NSString* const SoundThemeSoundIncorrectAnswer;
extern NSString* const SoundThemeSoundTimeUp;


// shared singleton object

@interface TriviaSoundController : NSObject {

	BOOL _mute;
	// contains the actual NSSound files keyed by sound name.
	NSMutableDictionary *_soundTheme;
	// Sound files available to use as sounds.
	NSMutableDictionary *_availableSounds;
	
	// the names of the sounds
	NSArray *_soundNames;
}

+ (TriviaSoundController *)defaultController;

- (BOOL)mute;
- (void)setMute:(BOOL)willMute;

- (NSArray *)availableSounds;
- (void)setSound:(NSString *)soundName toSoundFileNamed:(NSString *)soundFile;
- (void)playSound:(NSString *)soundName;
@end

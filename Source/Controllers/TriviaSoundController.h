//
//  TriviaSoundController.h
//  TriviaPlayer
//
//  Created by Nur Monson on 11/8/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* SoundThemeSoundGameStart;
extern NSString* SoundThemeSoundGameEnd;
extern NSString* SoundThemeSoundBuzzIn;
extern NSString* SoundThemeSoundCorrectAnswer;
extern NSString* SoundThemeSoundIncorrectAnswer;
extern NSString* SoundThemeSoundTimeUp;


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
- (NSString *)getSoundNameForSound:(NSString *)soundName;
- (void)setSound:(NSString *)soundName toSoundFileNamed:(NSString *)soundFile;
- (void)playSound:(NSString *)soundName;
@end

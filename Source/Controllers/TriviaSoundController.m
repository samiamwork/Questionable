//
//  TriviaSoundController.m
//  TriviaPlayer
//
//  Created by Nur Monson on 11/8/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaSoundController.h"

NSString* SoundThemeSoundGameStart = @"SoundGameStart";
NSString* SoundThemeSoundGameEnd = @"SoundGameEnd";
NSString* SoundThemeSoundBuzzIn = @"SoundBuzzIn";
NSString* SoundThemeSoundCorrectAnswer = @"SoundCorrectAnswer";
NSString* SoundThemeSoundIncorrectAnswer = @"SoundIncorrectAnswer";
NSString* SoundThemeSoundTimeUp = @"SoundTimeUp";


@interface TriviaSoundController (Private)
- (void)loadSounds;
@end

@implementation TriviaSoundController

+ (void)initialize
{
	NSMutableDictionary *themeSoundNames = [NSMutableDictionary dictionary];
	[themeSoundNames setValue:@"" forKey:SoundThemeSoundGameStart];
	[themeSoundNames setValue:@"" forKey:SoundThemeSoundGameEnd];
	[themeSoundNames setValue:@"Ping" forKey:SoundThemeSoundBuzzIn];
	[themeSoundNames setValue:@"Glass" forKey:SoundThemeSoundCorrectAnswer];
	[themeSoundNames setValue:@"Basso" forKey:SoundThemeSoundIncorrectAnswer];
	[themeSoundNames setValue:@"Basso" forKey:SoundThemeSoundTimeUp];
	
	//[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:themeSoundNames,@"sounds",nil]];
	[[NSUserDefaults standardUserDefaults] registerDefaults:themeSoundNames];
}

- (id)init
{
	if( (self = [super init]) ) {
		
		_soundTheme = [[NSMutableDictionary alloc] init];
		// Hard coding this is a bad idea but I know of no other way.
		NSMutableDictionary *systemDir = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSArray array],@"files",[NSDate distantPast],@"lastChange",nil];
		NSMutableDictionary *userDir = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSArray array],@"files",[NSDate distantPast],@"lastChange",nil];
		_availableSounds = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
							systemDir,@"/System/Library/Sounds",
							userDir,[@"~/Library/Sounds" stringByExpandingTildeInPath],
							nil];
		[self availableSounds];
		
		_mute = NO;
		
		_soundNames = [[NSArray alloc] initWithObjects:SoundThemeSoundGameStart, SoundThemeSoundGameEnd,
			SoundThemeSoundBuzzIn, SoundThemeSoundCorrectAnswer,
			SoundThemeSoundIncorrectAnswer, SoundThemeSoundTimeUp, nil];
		[self loadSounds];
	}
	
	return self;
}

- (void)dealloc
{	
	[_availableSounds release];	
	[_soundNames release];
	[_soundTheme release];
	[super dealloc];
}

+ (TriviaSoundController *)defaultController
{
	static TriviaSoundController *g_soundController = nil;
	
	if( g_soundController == nil ) {
		g_soundController = [[TriviaSoundController alloc] init];
	}
	
	return g_soundController;
}

- (void)loadSounds
{
	//NSMutableDictionary *sounds = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:@"sounds"]];
	NSFileManager *defaultManager = [NSFileManager defaultManager];
	
	NSString *soundName = nil;
	NSEnumerator *soundEnumerator = [_soundNames objectEnumerator];
	while( (soundName = [soundEnumerator nextObject]) ) {
		
		NSString *soundFile = [[NSUserDefaults standardUserDefaults] stringForKey:soundName];
		NSString *pathAndFile = nil;
		NSEnumerator *dirEnumerator = [_availableSounds keyEnumerator];
		NSString *thePath = nil;
		if( soundFile && [soundFile length] != 0 ) {
			while( (thePath = [dirEnumerator nextObject]) ) {
				pathAndFile = [thePath stringByAppendingPathComponent:[soundFile stringByAppendingPathExtension:@"aiff"]];
				if( [defaultManager fileExistsAtPath:pathAndFile] )
					break;
			}
		}
		
		if( thePath ) {
		
			// Loading the sound via "soundNamed:" keeps me from having to worry about
			// loading a sound twice.
			[_soundTheme setValue:[NSSound soundNamed:soundFile] forKey:soundName];
			
		} else {
			[[NSUserDefaults standardUserDefaults] setValue:nil forKey:soundName];
			[_soundTheme setValue:nil forKey:soundName];
		}
	}
	
	//[[NSUserDefaults standardUserDefaults] setValue:sounds forKey:@"sounds"];
}

# pragma mark Accessor Methods

- (BOOL)mute
{
	return _mute;
}
- (void)setMute:(BOOL)willMute
{
	_mute = willMute;
	
	//TODO: stop any playing sounds
}

- (NSArray *)audioFilesInDirectory:(NSString *)theDirectory
{
	NSMutableArray *audioFiles = [NSMutableArray array];
	
	NSFileManager *defaultManager = [NSFileManager defaultManager];
	NSEnumerator *fileEnumerator = [[defaultManager directoryContentsAtPath:theDirectory] objectEnumerator];
	NSString *file;
	while( (file = [fileEnumerator nextObject]) ) {
		BOOL isDirectory;
		// at the moment I'm only allowing .aiff sounds because that is what the system
		// expects to find in the system sound directories.
		if( [[[file pathExtension] lowercaseString] isEqualToString:@"aiff"] &&
		   [defaultManager fileExistsAtPath:[theDirectory stringByAppendingPathComponent:file] isDirectory:&isDirectory] &&
		   !isDirectory ) {
			
			[audioFiles addObject:[file stringByDeletingPathExtension]];
			
		}
	}
	
	return audioFiles;
}

- (NSArray *)availableSounds
{
	NSMutableArray *sounds = [NSMutableArray array];
	NSEnumerator *soundDirEnumerator = [_availableSounds keyEnumerator];
	NSString *dir;
	while( (dir = [soundDirEnumerator nextObject]) ) {
		NSMutableDictionary *dirDict = [_availableSounds objectForKey:dir];
		NSDate *lastChanged = [dirDict objectForKey:@"lastChanged"];
		NSDate *dirModified = [[[NSFileManager defaultManager] fileAttributesAtPath:dir traverseLink:YES] objectForKey:NSFileModificationDate];
		if( [dirModified laterDate:lastChanged] != lastChanged ) {
			[dirDict setValue:[self audioFilesInDirectory:dir] forKey:@"files"];
			[dirDict setValue:dirModified forKey:@"lastChanged"];
		}
		[sounds addObjectsFromArray:[dirDict valueForKey:@"files"]];
	}
	
	[sounds sortUsingSelector:@selector(localizedCompare:)];
	[sounds insertObject:@"" atIndex:0];

	return sounds;
}

- (NSString *)getSoundNameForSound:(NSString *)soundName
{
	if( ![_soundNames containsObject:soundName] )
		return nil;
	return [[NSUserDefaults standardUserDefaults] stringForKey:soundName];
}

- (void)setSound:(NSString *)soundName toSoundFileNamed:(NSString *)soundFile
{
	if( ![_soundNames containsObject:soundName] )
		return;
	
	//NSMutableDictionary *sounds = [ valueForKey:@"sounds"];
	if( !soundFile || [soundFile length] == 0 ) {
		[[NSUserDefaults standardUserDefaults] setValue:@"" forKey:soundName];
		return;
	}
	
	// make sure it's a sound file we know about
	NSEnumerator *directoryEnumerator = [_availableSounds keyEnumerator];
	NSString *dir;
	while( (dir = [directoryEnumerator nextObject]) ) {
		if( [(NSArray *)[[_availableSounds valueForKey:dir] valueForKey:@"files"] containsObject:soundFile] )
			break;
	}
	
	if( !dir )
		soundFile = nil;
	else
		[_soundTheme setValue:[NSSound soundNamed:soundFile] forKey:soundName];
	
	[[NSUserDefaults standardUserDefaults] setValue:soundFile forKey:soundName];
}

-  (void)playSound:(NSString *)soundName
{
	if( _mute )
		return;
	
	NSSound *soundToPlay = [_soundTheme valueForKey:soundName];
	if( !soundToPlay )
		return;
	
	if( [soundToPlay isPlaying] )
		[soundToPlay stop];
	[soundToPlay play];
}
@end

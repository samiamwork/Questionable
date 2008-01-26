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
		_sounds = [[NSMutableDictionary alloc] init];
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

// Returns nil if the file is not in any directory we care about.
// EXPECTS _availableSounds to be valid.
- (NSString *)pathToSoundFile:(NSString *)soundName
{
	if( !soundName || [soundName length] == 0 )
		return nil;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSEnumerator *dirEnumerator = [_availableSounds keyEnumerator];
	NSString *dir = nil;
	NSString *fullPath = nil;
	while( (dir = [dirEnumerator nextObject]) ) {
		fullPath = [dir stringByAppendingPathComponent:[soundName stringByAppendingPathExtension:@"aiff"]];
		if( [fileManager fileExistsAtPath:fullPath] )
			break;
	}
	
	return dir ? fullPath : nil;
}

- (void)loadSounds
{
	NSString *soundName = nil;
	NSEnumerator *soundEnumerator = [_soundNames objectEnumerator];
	while( (soundName = [soundEnumerator nextObject]) ) {	
		NSString *soundFile = [[NSUserDefaults standardUserDefaults] stringForKey:soundName];
		[self setSound:soundName toSoundFileNamed:soundFile];
	}
	
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
	// because we want to upload any sounds that no longer exist we are going to unload
	// the theme dict.
	[_soundTheme removeAllObjects];
	
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
	
	// reload sounds (they should all still be cached in the _sounds dict)
	[self loadSounds];
	NSEnumerator *soundFileEnumerator = [_sounds keyEnumerator];
	NSString *soundFile;
	while( (soundFile = [soundFileEnumerator nextObject]) ) {
		NSSound *theSound = [_sounds valueForKey:soundFile];
		if( theSound && [theSound retainCount] == 1 )
			[_sounds removeObjectForKey:soundFile];
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

- (void)setSound:(NSString *)soundName toSound:(NSSound *)theSound
{
	NSSound *oldSound = [_soundTheme valueForKey:soundName];
	[_soundTheme setValue:theSound forKey:soundName];
	// If the retainCount for this sound is one, then the only reference to this
	// sound is in the _sounds dict and is not in use, so it needs to be unloaded.
	if( oldSound && [oldSound retainCount] == 1 )
		[_sounds setValue:nil forKey:soundName];
}

// attempts to load the sound into the _soundTheme dict.
// if the sound file is not represented on the disk, it will not load the sound file.
// if the sound file is on the disk then it will try to use an already loaded version,
// before finally giving up and loading it from disk.
- (void)setSound:(NSString *)soundName toSoundFileNamed:(NSString *)soundFile
{
	if( ![_soundNames containsObject:soundName] )
		return;
	
	if( !soundFile || [soundFile length] == 0 ) {
		[[NSUserDefaults standardUserDefaults] setValue:@"" forKey:soundName];
		return;
	}

	NSString *soundFilePath = [self pathToSoundFile:soundFile];
	if( !soundFilePath ) {
		// since the file is nil we need to unload the sound file.
		[self setSound:soundName toSound:nil];
		[[NSUserDefaults standardUserDefaults] setValue:@"" forKey:soundName];
		return;
	}
	
	// if the sound is already loaded use that object
	NSSound *loadedSound = [_sounds valueForKey:soundFile];
	if( loadedSound )
		[self setSound:soundName toSound:loadedSound];
	else {
		NSSound *newSound = [[NSSound alloc] initWithContentsOfFile:soundFilePath byReference:YES];
		[_soundTheme setValue:newSound forKey:soundName];
		[_sounds setValue:newSound forKey:soundFile];
		[newSound release];
	}

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

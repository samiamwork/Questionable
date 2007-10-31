//
//  TriviaSoundController.m
//  TriviaPlayer
//
//  Created by Nur Monson on 11/8/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaSoundController.h"

NSString *SoundThemeSoundGameStart = @"Game Start";
NSString *SoundThemeSoundGameEnd = @"Game End";
NSString *SoundThemeSoundRoundStart = @"Round Start";
NSString *SoundThemeSoundRoundEnd = @"Round End";
NSString *SoundThemeSoundBuzzIn = @"Buzz In";
NSString *SoundThemeSoundCorrectAnswer = @"Correct Answer";
NSString *SoundThemeSoundIncorrectAnswer = @"Incorrect Answer";
NSString *SoundThemeSoundTimeUp = @"Time Up";

NSString *SoundThemeNameDefault = @"Default Theme";

@interface TriviaSoundController (Private)
- (void)readThemes;
@end

@implementation TriviaSoundController

- (id)init
{
	if( (self = [super init]) ) {
		
		selectedTheme = nil;
		// not used yet...
		availableSounds = nil;
		
		mute = NO;
		themes = [[NSMutableDictionary alloc] init];
		
		soundNames = [[NSArray alloc] initWithObjects:SoundThemeSoundGameStart, SoundThemeSoundGameEnd,
			SoundThemeSoundRoundStart, SoundThemeSoundRoundEnd, SoundThemeSoundBuzzIn, SoundThemeSoundCorrectAnswer,
			SoundThemeSoundIncorrectAnswer, SoundThemeSoundTimeUp, nil];
		[self readThemes];
		[self setSelectedTheme:SoundThemeNameDefault];
	}
	
	return self;
}

- (void)dealloc
{	
	if( availableSounds )
		[availableSounds release];
	
	[soundNames release];
	[themes release];
	
	[super dealloc];
}

+ (TriviaSoundController *)defaultController
{
	static TriviaSoundController *g_soundController = nil;
	
	if( g_soundController == nil ) {
		// I wanted an autorelease here before but normally you don't have to
		// release singletons because they're going to stay around the whole
		// time anyway and there will only be one of them.
		g_soundController = [[TriviaSoundController alloc] init];
	}
	
	return g_soundController;
}

- (void)readThemes
{
	// reset themes dictionary
	[themes removeAllObjects];
	
	// setup default theme
	NSMutableDictionary *aTheme = [NSMutableDictionary dictionary];
	[aTheme setObject:SoundThemeNameDefault forKey:@"name"];
	
	
	NSMutableDictionary *themeSoundNames = [NSMutableDictionary dictionary];
	[themeSoundNames setValue:nil forKey:SoundThemeSoundGameStart];
	[themeSoundNames setValue:nil forKey:SoundThemeSoundGameEnd];
	[themeSoundNames setValue:nil forKey:SoundThemeSoundRoundStart];
	[themeSoundNames setValue:nil forKey:SoundThemeSoundRoundEnd];
	[themeSoundNames setValue:@"Ping" forKey:SoundThemeSoundBuzzIn];
	[themeSoundNames setValue:@"Glass" forKey:SoundThemeSoundCorrectAnswer];
	[themeSoundNames setValue:@"Basso" forKey:SoundThemeSoundIncorrectAnswer];
	[themeSoundNames setValue:@"Basso" forKey:SoundThemeSoundTimeUp];
	
	[aTheme setValue:themeSoundNames forKey:@"soundNames"];
	
	[themes setValue:aTheme forKey:SoundThemeNameDefault];
	//TODO: load other themes from bundle...

}

# pragma mark Accessor Methods

- (BOOL)mute
{
	return mute;
}
- (void)setMute:(BOOL)willMute
{
	mute = willMute;
	
	//TODO: stop any playing sounds
}

- (NSArray *)themes
{
	return [themes allKeys];
}

- (void)setSelectedTheme:(NSString *)aThemeName
{
	if( [[selectedTheme valueForKey:@"name"] isEqualToString:aThemeName] )
		return;
	
	NSDictionary *newTheme = [themes objectForKey:aThemeName];
	if( !newTheme )
		return;
	
	// unload old theme's sounds because we only want one loaded at a time
	[selectedTheme setValue:nil forKey:@"soundObjects"];
	selectedTheme = [themes valueForKey:aThemeName];
	
	NSMutableDictionary *soundObjects = [NSMutableDictionary dictionary];
	NSEnumerator *soundEnumerator = [soundNames objectEnumerator];
	NSString *soundName;
	while( (soundName = [soundEnumerator nextObject]) )
		[soundObjects setValue:[NSSound soundNamed:[[newTheme valueForKey:@"soundNames"] valueForKey:soundName]] forKey:soundName];
	
	[selectedTheme setValue:soundObjects forKey:@"soundObjects"];
	//[newTheme setValue:[NSNumber numberWithBool:YES] forKey:@"loaded"];
}
- (NSString *)selectedTheme
{
	return [selectedTheme valueForKey:@"name"];
}

-  (void)playSound:(NSString *)soundName
{
	if( mute )
		return;
	
	NSDictionary *soundObjects = [selectedTheme valueForKey:@"soundObjects"];
	if( !soundObjects )
		return;
	NSSound *soundToPlay = [soundObjects valueForKey:soundName];
	if( !soundToPlay )
		return;
	
	if( [soundToPlay isPlaying] )
		[soundToPlay stop];
	[soundToPlay play];
}
@end

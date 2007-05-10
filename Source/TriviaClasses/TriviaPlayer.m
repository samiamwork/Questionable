//
//  TriviaPlayer.m
//  TriviaPlayer
//
//  Created by Nur Monson on 9/25/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaPlayer.h"


@implementation TriviaPlayer

- (id)init
{
	if( (self = [super init]) ) {
		
		inputElement = nil;
		
		theName = @"no name";
		thePoints = 0;
		enabled = NO;
		
	}
	
	return self;
}

- (void)dealloc
{
	[theName release];
	[inputElement release];
	
	[super dealloc];
}

- (NSString *)name
{
	return theName;
}
- (void)setName:(NSString *)newName
{
	if( newName == theName )
		return;
	
	[theName release];
	theName = [newName retain];
}

- (int)points
{
	return thePoints;
}
- (void)setPoints:(int)newPoints
{
	thePoints = newPoints;
}
- (void)addPoints:(int)addPoints
{
	thePoints += addPoints;
}
- (void)subtractPoints:(int)subtractPoints
{
	thePoints -= subtractPoints;
}


- (BOOL)enabled
{
	return enabled;
}
- (void)setEnabled:(BOOL)isEnabled
{
	enabled = isEnabled;
}

- (NSComparisonResult)sortByPoints:(id)anotherPlayer
{
	if( [(TriviaPlayer *)anotherPlayer points] > [self points] )
		return NSOrderedDescending;
	else if( [(TriviaPlayer *)anotherPlayer points] == [self points] )
		return NSOrderedSame;
	
	return NSOrderedAscending;
}

- (BOOL)isConnected
{
	if( inputElement == nil )
		return NO;
	
	return YES;
}
/*
- (void)registerInput
{	
	[self willChangeValueForKey:@"isConnected"];
	inputElement = [[TIPInputManager defaultManager] getAnyElementWithTimeout:5.0];
		
	[self didChangeValueForKey:@"isConnected"];
}
*/
- (TIPInputElement *)inputElement
{
	return inputElement;
}
- (void)setInputElement:(TIPInputElement *)newElement
{
	if( newElement == inputElement )
		return;
	
	//printf("%s: u = %ld, up = %ld\n", [theName cString], [newElement usage], [newElement usagePage] );
	if( inputElement != nil )
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:@"TIPInputDeviceDisconnected"
													  object:[inputElement device]];
	if( newElement != nil )
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(deviceDisconnected:)
													 name:@"TIPInputDeviceDisconnected"
												   object:[newElement device]];
	[self willChangeValueForKey:@"isConnected"];
	[inputElement release];
	inputElement = [newElement retain];
	[self didChangeValueForKey:@"isConnected"];
	
}

- (void)deviceDisconnected:(NSNotification *)aNotification
{
	[self setInputElement:nil];
}

- (BOOL)isButtonPressed
{
	if( !enabled || inputElement == nil )
		return NO;
	
	long value = [inputElement getValue];
	if( value ) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TIPTriviaPlayerBuzzed" object:self];
		return YES;
	}

	return  NO;
}

// light up for buttons pressed
@end

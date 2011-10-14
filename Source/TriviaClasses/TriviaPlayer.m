//
//  TriviaPlayer.m
//  TriviaPlayer
//
//  Created by Nur Monson on 9/25/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaPlayer.h"


@implementation TriviaPlayer

@synthesize pressed;

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
	if([key isEqualToString:@"status"])
		return [NSSet setWithObjects:@"connected", @"pressed", nil];
	return [super keyPathsForValuesAffectingValueForKey:key];
}

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
	[self willChangeValueForKey:@"points"];
	thePoints += addPoints;
	[self didChangeValueForKey:@"points"];
}
- (void)subtractPoints:(int)subtractPoints
{
	[self willChangeValueForKey:@"points"];
	thePoints -= subtractPoints;
	[self didChangeValueForKey:@"points"];
}

- (NSInteger)status
{
	if(pressed)
	{
		return 2;
	}
	else if([self connected])
	{
		return 1;
	}
	return 0;
}

- (BOOL)pressed
{
	return pressed;
}
- (void)setPressed:(BOOL)shouldPress
{
	pressed = shouldPress;
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

- (BOOL)connected
{
	if( inputElement == nil )
		return NO;
	
	return YES;
}

- (TIPInputElement *)inputElement
{
	return inputElement;
}
- (void)setInputElement:(TIPInputElement *)newElement
{
	if( newElement == inputElement )
		return;

	if( inputElement != nil )
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:@"TIPInputDeviceDisconnected"
													  object:[inputElement device]];
	if( newElement != nil )
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(deviceDisconnected:)
													 name:@"TIPInputDeviceDisconnected"
												   object:[newElement device]];
	[self willChangeValueForKey:@"connected"];
	[inputElement release];
	inputElement = [newElement retain];
	[self didChangeValueForKey:@"connected"];
}

- (void)deviceDisconnected:(NSNotification *)aNotification
{
	[self setInputElement:nil];
}

// light up for buttons pressed
@end

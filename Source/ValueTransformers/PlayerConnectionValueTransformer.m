//
//  PlayerConnectionValueTransformer.m
//  ShippoSearch
//
//  Created by Nur Monson on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayerConnectionValueTransformer.h"

@implementation PlayerConnectionValueTransformer

+ (Class)transformedValueClass
{
	return [NSImage class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)init
{
	self = [super init];
	if(self != nil)
	{
		_red   = [[NSImage imageNamed:@"jewel red"] retain];
		_green = [[NSImage imageNamed:@"jewel green"] retain];
		_blue  = [[NSImage imageNamed:@"jewel blue"] retain];
	}

	return self;
}

- (void)dealloc
{
	[_red release];
	[_green release];
	[_blue release];

	[super dealloc];
}

- (id)transformedValue:(id)value
{
	switch([(NSNumber*)value integerValue])
	{
		case 0: return _red;   break;
		case 1: return _green; break;
		case 2: return _blue;  break;
	}
	return nil;
}

@end

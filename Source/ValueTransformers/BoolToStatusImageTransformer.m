//
//  BoolToStatusImageTransformer.m
//  Questionable
//
//  Created by Nur Monson on 2/13/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "BoolToStatusImageTransformer.h"


@implementation BoolToStatusImageTransformer

+ (Class)transformedValueClass
{
	return [NSImage class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
	return [value boolValue] ? [NSImage imageNamed:@"jewel green"] : [NSImage imageNamed:@"jewel red"];
}

@end

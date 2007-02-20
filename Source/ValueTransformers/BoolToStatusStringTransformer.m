//
//  BoolToStatusStringTransformer.m
//  Questionable
//
//  Created by Nur Monson on 2/13/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "BoolToStatusStringTransformer.h"


@implementation BoolToStatusStringTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
	return [value boolValue] ? @"Assigned" : @"Unassigned";
}

@end

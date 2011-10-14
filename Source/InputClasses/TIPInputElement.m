//
//  TIPInputElement.m
//  HIDInputUtils
//
//  Created by Nur Monson on 11/16/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TIPInputElement.h"

@interface TIPInputDevice
- (IOHIDDeviceInterface **)deviceInterface;
@end

@implementation TIPInputElement

+ (id)elementWithElementRef:(IOHIDElementRef)theElement device:(TIPInputDevice*)device
{
	return [[[TIPInputElement alloc] initWithElementRef:theElement device:device] autorelease];
}

- (id)initWithElementRef:(IOHIDElementRef)theElement device:(TIPInputDevice*)device
{
	self = [super init];
	if(self != nil)
	{
		_element = theElement;
		CFRetain(_element);
	}

	return self;
}

- (void)dealloc
{
	CFRelease(_element);
	
	[super dealloc];
}

- (TIPInputDevice*)device
{
	return _device;
}

@end

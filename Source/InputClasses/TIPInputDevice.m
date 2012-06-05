//
//  TIPInputDevice.m
//  HIDInputUtils
//
//  Created by Nur Monson on 11/15/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TIPInputDevice.h"


@implementation TIPInputDevice

- (void)dealloc
{
	[manufacturer release];
	[product release];
	[serial release];
	[_elements release];

	IOHIDDeviceClose(_device, kIOHIDOptionsTypeNone);
	CFRelease(_device);
	
	[super dealloc];
}

+ (id)deviceWithDeviceRef:(IOHIDDeviceRef)theDevice exclusive:(BOOL)exclusive
{
	if(theDevice == NULL)
		return nil;

	TIPInputDevice* newDevice = [[TIPInputDevice alloc] initWithDeviceRef:theDevice exclusive:exclusive];
	return newDevice;
}

- (void)valueChanged:(IOHIDValueRef)value
{
	IOHIDElementRef theElement = IOHIDValueGetElement(value);
	if(IOHIDElementGetType(theElement) != kIOHIDElementTypeInput_Button)
	{
		// Ignore elements that aren't strictly buttons, for now.
		return;
	}

	NSNumber* cookie = [NSNumber numberWithUnsignedInteger:(NSUInteger)IOHIDElementGetCookie(theElement)];
	if([_elements objectForKey:cookie] == nil)
	{
		TIPInputElement* newElement = [TIPInputElement elementWithElementRef:theElement device:self];
		[_elements setObject:newElement forKey:cookie];
	}
	if(IOHIDValueGetIntegerValue(value) > 0)
	{
		if(_delegate != nil && [(NSObject*)_delegate respondsToSelector:@selector(TIPInputDevice:buttonPressed:)])
		{
			[_delegate TIPInputDevice:self buttonPressed:[_elements objectForKey:cookie]];
		}
	}
	else if(IOHIDValueGetIntegerValue(value) == 0)
	{
		if(_delegate != nil)
		{
			[_delegate TIPInputDevice:self buttonReleased:[_elements objectForKey:cookie]];
		}
	}
}

static void HIDValueCallback(void *ctx, IOReturn result, void *sender, IOHIDValueRef value)
{
	[(TIPInputDevice*)ctx valueChanged:value];
}

- (id)initWithDeviceRef:(IOHIDDeviceRef)theDevice exclusive:(BOOL)exclusive
{
	self = [super init];
	if(self != nil)
	{
		_device = theDevice;
		IOHIDDeviceRegisterInputValueCallback(_device, &HIDValueCallback, self);
		CFRetain(theDevice);
		IOReturn result;
		if(exclusive)
		{
			// If we want to get exclusive access (we do, especially for things like mice)
			// we need to close the device. The result isn't success but exclusive access
			// appears to not work otherwise
			result = IOHIDDeviceClose(theDevice, 0);
			result = IOHIDDeviceOpen(theDevice, kIOHIDOptionsTypeSeizeDevice);
		}
		else
		{
			result = IOHIDDeviceOpen(theDevice, kIOHIDOptionsTypeNone);
		}
		if(result != kIOReturnSuccess)
			NSLog(@"error opening device");
		_elements = [[NSMutableDictionary alloc] init];
		NSNumber* locationNumber = (NSNumber*)IOHIDDeviceGetProperty(theDevice, CFSTR(kIOHIDLocationIDKey));
		locationID = [locationNumber longValue];
	}

	return self;
}

- (long)locationID
{
	return locationID;
}
- (IOHIDDeviceRef)deviceRef
{
	return _device;
}

- (void)setDelegate:(id<TIPInputDeviceDelegate>)delegate
{
	_delegate = delegate;
}

@end

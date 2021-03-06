//
//  TIPInputManager.m
//  HIDInputUtils
//
//  Created by Nur Monson on 11/14/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TIPInputManager.h"
#import <IOKit/IOKitLib.h>
#import <IOKit/hid/IOHIDUsageTables.h>
#import <IOKit/hid/IOHIDKeys.h>

#define ENABLE_KEYBOARDS 0

@implementation TIPInputManager

void HIDAddDevice(void* ctx, IOReturn result, void* sender, IOHIDDeviceRef device);
void HIDRemoveDevice(void* ctx, IOReturn result, void* sender, IOHIDDeviceRef device);

- (id) init
{
	self = [super init];
	if (self != nil) {
		_hidManager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
		_devices    = [[NSMutableSet alloc] init];

		IOReturn result = kIOReturnSuccess;
		
		// set up dictionary describing matching devices of interest
		//NSMutableDictionary *HIDMatchingDictionary = [NSMutableDictionary dictionary];
		
		NSNumber *usagePage = [NSNumber numberWithInt:kHIDPage_GenericDesktop];
		
		NSMutableArray *deviceUsagePairs = [NSMutableArray array];
		NSMutableDictionary *joystickDictionary = [NSMutableDictionary dictionary];
		NSMutableDictionary *gamepadDictionary = [NSMutableDictionary dictionary];
		NSMutableDictionary *mouseDictionary = [NSMutableDictionary dictionary];
		
		[joystickDictionary setValue:usagePage forKey:@kIOHIDDeviceUsagePageKey];
		[gamepadDictionary setValue:usagePage forKey:@kIOHIDDeviceUsagePageKey];
		[mouseDictionary setValue:usagePage forKey:@kIOHIDDeviceUsagePageKey];

		[joystickDictionary setValue:[NSNumber numberWithInt:kHIDUsage_GD_Joystick] forKey:@kIOHIDDeviceUsageKey];
		[deviceUsagePairs addObject:joystickDictionary];

		[gamepadDictionary setValue:[NSNumber numberWithInt:kHIDUsage_GD_GamePad] forKey:@kIOHIDDeviceUsageKey];
		[deviceUsagePairs addObject:gamepadDictionary];

		if(ENABLE_KEYBOARDS)
		{
			NSMutableDictionary *keyboardDictionary = [NSMutableDictionary dictionary];
			[keyboardDictionary setValue:usagePage forKey:@kIOHIDDeviceUsagePageKey];
			[keyboardDictionary setValue:[NSNumber numberWithInt:kHIDUsage_GD_Keyboard] forKey:@kIOHIDDeviceUsageKey];
			[deviceUsagePairs addObject:keyboardDictionary];
		}
		
		[mouseDictionary setValue:[NSNumber numberWithInt:kHIDUsage_GD_Mouse] forKey:@kIOHIDDeviceUsageKey];
		[deviceUsagePairs addObject:mouseDictionary];
		
		IOHIDManagerSetDeviceMatchingMultiple(_hidManager, (CFArrayRef)deviceUsagePairs);
		IOHIDManagerRegisterDeviceMatchingCallback(_hidManager, &HIDAddDevice, self);
		IOHIDManagerRegisterDeviceRemovalCallback(_hidManager, &HIDRemoveDevice, self);
		CFRunLoopAddCommonMode(CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
		CFRunLoopAddCommonMode(CFRunLoopGetCurrent(), (CFStringRef)NSModalPanelRunLoopMode);
		IOHIDManagerScheduleWithRunLoop(_hidManager, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
		result = IOHIDManagerOpen(_hidManager, kIOHIDOptionsTypeNone);

		// Grab devices that are already connected and get non-exclusive access to them.
		// We do this so we can distinguish between devices that were connected before
		// we started the app and those connected after.
		NSSet* devices = (NSSet*)IOHIDManagerCopyDevices(_hidManager);
		for(id aDevice in devices)
		{
			IOHIDDeviceRef device = (IOHIDDeviceRef)aDevice;
			TIPInputDevice* newDevice = [TIPInputDevice deviceWithDeviceRef:device exclusive:NO];
			[newDevice setDelegate:self];
			[_devices addObject:newDevice];
		}
		[devices release];

		_delegate = nil;
	}
	return self;
}

- (void) dealloc
{
	IOHIDManagerClose(_hidManager, kIOHIDOptionsTypeNone);
	IOHIDManagerUnscheduleFromRunLoop(_hidManager, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
	CFRelease(_hidManager);
	[_devices release];
	
	[super dealloc];
}

+ (TIPInputManager *)defaultManager
{
	static TIPInputManager *g_inputManager = nil;
	
	if( g_inputManager == nil ) {
		// I wanted an autorelease here before but normally you don't have to
		// release singletons because they're going to stay around the whole
		// time anyway and there will only be one of them.
		g_inputManager = [[TIPInputManager alloc] init];
	}
	
	return g_inputManager;
}

- (void)setDelegate:(NSObject<TIPInputManagerDelegate>*)newDelegate
{
	_delegate = newDelegate;
}

- (void)getAnyElementWithTimeout:(NSTimeInterval)timeout;
{
	// Set a value callback
	_waitingForNewButton = YES;
	_elementCheckTimer = [NSTimer timerWithTimeInterval:timeout target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:_elementCheckTimer forMode:NSModalPanelRunLoopMode];
}

- (void)timeout:(NSTimer*)aTimer
{
	[_elementCheckTimer invalidate];
	_elementCheckTimer = nil;
	if( _delegate != nil && [_delegate respondsToSelector:@selector(elementSearchFinished:)] )
		[_delegate elementSearchFinished:nil];
}

- (void)addDevice:(IOHIDDeviceRef)newDevice
{
	NSNumber* locationNumber = (NSNumber*)IOHIDDeviceGetProperty(newDevice, CFSTR(kIOHIDLocationIDKey));
	for(TIPInputDevice* device in _devices)
	{
		if([device locationID] == [locationNumber longValue])
		{
			// we already have the device so bail out
			// this happens after launching the program because we get non-exclusive access
			// to devices already connected when we launch.
			return;
		}
	}
	TIPInputDevice* device = [TIPInputDevice deviceWithDeviceRef:newDevice exclusive:YES];
	[device setDelegate:self];
	[_devices addObject:device];
}

- (void)removeDevice:(IOHIDDeviceRef)deviceToRemove
{
	NSNumber* locationNumber = (NSNumber*)IOHIDDeviceGetProperty(deviceToRemove, CFSTR(kIOHIDLocationIDKey));
	// This is stupid but effective and simple
	for(TIPInputDevice* device in _devices)
	{
		if([device locationID] == [locationNumber longValue])
		{
			// Give device a chance to notify anyone listening to elements
			//[device willRemove];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"TIPInputDeviceDisconnected" object:device];
			[_devices removeObject:device];
			break;
		}
	}
}

// Device delegate function
- (void)TIPInputDevice:(TIPInputDevice*)theDevice buttonPressed:(TIPInputElement*)theElement
{
	if(_elementCheckTimer != nil)
	{
		// we're waitng configuring input for someone
		[_elementCheckTimer invalidate];
		_elementCheckTimer = nil;
		if(_delegate != nil)
		{
			[_delegate elementSearchFinished:theElement];
		}
	}
	else
	{
		// we're just getting button presses
		if(_delegate != nil)
		{
			[_delegate inputManager:self elementPressed:theElement];
		}
	}
}

- (void)TIPInputDevice:(TIPInputDevice*)theDevice buttonReleased:(TIPInputElement*)theElement
{
	if(_elementCheckTimer != nil)
	{
		return;
	}
	if(_delegate != nil)
	{
		[_delegate inputManager:self elementReleased:theElement];
	}
}

#pragma mark C USB functions

void HIDAddDevice(void* ctx, IOReturn result, void* sender, IOHIDDeviceRef device)
{
	[(TIPInputManager*)ctx addDevice:device];
}

void HIDRemoveDevice(void* ctx, IOReturn result, void* sender, IOHIDDeviceRef device)
{
	[(TIPInputManager*)ctx removeDevice:device];
}

@end

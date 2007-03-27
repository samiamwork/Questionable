//
//  TIPInputManager.m
//  HIDInputUtils
//
//  Created by Nur Monson on 11/14/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TIPInputManager.h"
#import <IOKit/IOKitLib.h>
#import <IOKit/hid/IOHIDLib.h>
#import <IOKit/hid/IOHIDUsageTables.h>

@interface NSObject (delegate)
- (void)elementSearchFinished:(TIPInputElement *)foundElement;
@end

@implementation TIPInputManager

void HIDAddDevices( void *managerRef, io_iterator_t iterator );
void HIDRemoveDevices( void *managerRef, io_iterator_t iterator );

- (id) init {
	self = [super init];
	if (self != nil) {
		// normal
		deviceArray = [[NSMutableArray alloc] init];
		// end normal
		IOReturn result = kIOReturnSuccess;
		
		// set up dictionary describing matching devices of interest
		NSMutableDictionary *HIDMatchingDictionary = (NSMutableDictionary *)IOServiceMatching( kIOHIDDeviceKey );
		
		NSMutableArray *deviceUsagePairs = [NSMutableArray array];
		NSMutableDictionary *joystickDictionary = [NSMutableDictionary dictionary];
		NSMutableDictionary *gamepadDictionary = [NSMutableDictionary dictionary];
		
		NSNumber *usagePage = [NSNumber numberWithInt:kHIDPage_GenericDesktop];
		[joystickDictionary setValue:usagePage forKey:@kIOHIDDeviceUsagePageKey];
		[gamepadDictionary setValue:usagePage forKey:@kIOHIDDeviceUsagePageKey];

		[joystickDictionary setValue:[NSNumber numberWithInt:kHIDUsage_GD_Joystick] forKey:@kIOHIDDeviceUsageKey];
		[deviceUsagePairs addObject:joystickDictionary];

		[gamepadDictionary setValue:[NSNumber numberWithInt:kHIDUsage_GD_GamePad] forKey:@kIOHIDDeviceUsageKey];
		[deviceUsagePairs addObject:gamepadDictionary];
		
		[HIDMatchingDictionary setValue:deviceUsagePairs forKey:@kIOHIDDeviceUsagePairsKey];
		
		// get an iterator of all currently connected devices that we're interested in
		removedDeviceIterator = 0;
		addedDeviceIterator = 0;
		[HIDMatchingDictionary retain];
		result = IOServiceGetMatchingServices( kIOMasterPortDefault, (CFDictionaryRef )HIDMatchingDictionary, &addedDeviceIterator );
		if( result != kIOReturnSuccess )
			printf("could not find any matching devices!\n");
		
		// register for device added notifications
		IONotificationPortRef notificationObject = IONotificationPortCreate( kIOMasterPortDefault );
		CFRunLoopSourceRef notificationRunLoopSource = IONotificationPortGetRunLoopSource( notificationObject );
		CFRunLoopAddSource( CFRunLoopGetCurrent(), notificationRunLoopSource, kCFRunLoopDefaultMode );
		
		// this will consume a reference
		[HIDMatchingDictionary retain];
		result = IOServiceAddMatchingNotification( notificationObject, kIOFirstMatchNotification, (CFDictionaryRef )HIDMatchingDictionary, HIDAddDevices, self, &addedDeviceIterator);
		// register for device removed notifications
		[HIDMatchingDictionary retain];
		result = IOServiceAddMatchingNotification( notificationObject, kIOTerminatedNotification, (CFDictionaryRef )HIDMatchingDictionary, HIDRemoveDevices, self, &removedDeviceIterator);
		
		// build the device list release the itterator
		HIDAddDevices( self, addedDeviceIterator);
		// activate device removal notifications by using the iterator
		HIDRemoveDevices( self, removedDeviceIterator);
		
		_delegate = nil;
	}
	return self;
}

- (void) dealloc {
	// nothing yet
	[super dealloc];
	
	[deviceArray release];
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

- (id)delegate
{
	return _delegate;
}
- (void)setDelegate:(id)newDelegate
{
	_delegate = newDelegate;
}

- (NSArray *)devices
{
	return (NSArray *)deviceArray;
}

- (void)getAnyElementWithTimeout:(NSTimeInterval)timeout;
{
	// save current input state of all devices and elements
	// loop through all objects waiting for the first element in
	// any device that shows a change of more than X%.
	
	// set all the elements reference Values
	TIPInputDevice *aDevice;
	NSEnumerator *deviceEnumerator = [deviceArray objectEnumerator];
	while( (aDevice = [deviceEnumerator nextObject]) ) {
		TIPInputElement *anElement;
		NSEnumerator *elementEnumerator = [[aDevice elements] objectEnumerator];
		while( (anElement = [elementEnumerator nextObject]) )
			[anElement setReferenceValue];
	}
	
	_elementCheckTimeout = timeout;
	_startTime = [NSDate timeIntervalSinceReferenceDate];
	_elementCheckTimer = [NSTimer timerWithTimeInterval:1.0/30.0 target:self selector:@selector(checkElements:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:_elementCheckTimer forMode:NSModalPanelRunLoopMode];
}

- (void)checkElements:(NSTimer *)aTimer
{
	TIPInputElement *differentElement = nil;
	
	TIPInputDevice *aDevice;
	NSEnumerator *deviceEnumerator = [deviceArray objectEnumerator];
	while( (aDevice = [deviceEnumerator nextObject]) && differentElement == nil) {
		
		NSEnumerator *elementEnumerator = [[aDevice elements] objectEnumerator];
		TIPInputElement *anElement;
		while( (anElement = [elementEnumerator nextObject]) && differentElement == nil)
			differentElement = [anElement isDifferentThanReference];			
		
	}
	
	if( [NSDate timeIntervalSinceReferenceDate] - _startTime > _elementCheckTimeout || differentElement != nil ) {
		[_elementCheckTimer invalidate];
		_elementCheckTimer = nil;
		if( _delegate != nil && [_delegate respondsToSelector:@selector(elementSearchFinished:)] )
			[_delegate elementSearchFinished:differentElement];
	}
}

- (void)removeDeviceAtLocation:(long)aLocation
{
	NSEnumerator *deviceEnumerator = [deviceArray objectEnumerator];
	TIPInputDevice *aDevice;
	aDevice = [deviceEnumerator nextObject];
	while( aDevice && [aDevice locationID] != aLocation )
		aDevice = [deviceEnumerator nextObject];
	
	if( aDevice ) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TIPInputDeviceDisconnected" object:aDevice];
		[deviceArray removeObject:aDevice];
		//printf("device removed!\n");
	}
	
	//printf("device count = %d\n", [deviceArray count]);	
}
#pragma mark C USB functions

void HIDAddDevices( void *managerRef, io_iterator_t iterator )
{
	TIPInputManager *manager = (TIPInputManager *)managerRef;
	io_object_t ioObject;
	
	while( (ioObject = IOIteratorNext(iterator)) ) {
		//printf("device added!\n");
		
		[manager->deviceArray addObject:[TIPInputDevice deviceWithIOObject:ioObject]];
		// apparently we need to release it
		IOObjectRelease(ioObject);
		
		//printf("Device count = %d\n", [manager->deviceArray count]);
	}
}

void HIDRemoveDevices( void *managerRef, io_iterator_t iterator )
{
	TIPInputManager *manager = (TIPInputManager *)managerRef;
	io_object_t ioObject;
	
	while( (ioObject = IOIteratorNext(iterator)) ) {
		// need to be able to find device in device array by io_object_t
		IOReturn result;
		NSMutableDictionary *removedDescription;
		result = IORegistryEntryCreateCFProperties( ioObject, (CFMutableDictionaryRef *)&removedDescription, kCFAllocatorDefault, kNilOptions);
		long removedLocationID = [[removedDescription valueForKey:@kIOHIDLocationIDKey] longValue];
		
		[manager removeDeviceAtLocation:removedLocationID];
		
		[removedDescription release];
	}	
}

@end

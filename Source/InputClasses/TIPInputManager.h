//
//  TIPInputManager.h
//  HIDInputUtils
//
//  Created by Nur Monson on 11/14/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TIPInputDevice.h"

/*!
	@class TIPInputManager
	@abstract   class for accessing USB input devices
	@discussion This class is intended to be used as a singleton from it's "default" instance obtained
	by calling "defaultManager." Use this instance to get and configure input devices and their elements.
	Currently this is only designed to support HID devices (specifically gamepads and joysticks).
*/

@interface TIPInputManager : NSObject {
	io_iterator_t addedDeviceIterator;
	io_iterator_t removedDeviceIterator;
	
	NSMutableArray *deviceArray;
	id _delegate;
	NSTimeInterval _elementCheckTimeout;
	NSTimeInterval _startTime;
	NSTimer *_elementCheckTimer;
}

/*!
	@method defaultManager
	@abstract   returns the default input manager instance.
	@discussion Since this class is intended to work as a singleton you normally should not alloc your own
	instance. Instead you should always call this method to aquire the default instance.
*/

+ (TIPInputManager *)defaultManager;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;
- (NSArray *)devices;
- (void)getAnyElementWithTimeout:(NSTimeInterval)timeout;
@end

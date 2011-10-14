//
//  TIPInputManager.h
//  HIDInputUtils
//
//  Created by Nur Monson on 11/14/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TIPInputDevice.h"
#import <IOKit/hid/IOHIDLib.h>
//#import "TriviaSoundController.h"

/*!
	@class TIPInputManager
	@abstract   class for accessing USB input devices
	@discussion This class is intended to be used as a singleton from it's "default" instance obtained
	by calling "defaultManager." Use this instance to get and configure input devices and their elements.
	Currently this is only designed to support HID devices (specifically gamepads and joysticks).
*/

@class TIPInputManager;
@protocol TIPInputManagerDelegate
- (void)elementSearchFinished:(TIPInputElement*)foundElement;
- (void)inputManager:(TIPInputManager*)inputManager elementPressed:(TIPInputElement*)element;
- (void)inputManager:(TIPInputManager *)inputManager elementReleased:(TIPInputElement *)element;
@end

@interface TIPInputManager : NSObject<TIPInputDeviceDelegate> {
	IOHIDManagerRef _hidManager;
	BOOL            _waitingForNewButton;
	NSMutableSet*   _devices;

	io_iterator_t addedDeviceIterator;
	io_iterator_t removedDeviceIterator;
	
	NSObject<TIPInputManagerDelegate>* _delegate;
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

- (void)setDelegate:(NSObject<TIPInputManagerDelegate>*)newDelegate;
- (void)getAnyElementWithTimeout:(NSTimeInterval)timeout;
- (void)TIPInputDevice:(TIPInputDevice*)theDevice buttonPressed:(TIPInputElement*)theElement;
@end


@interface NSObject (delegate)
- (void)elementSearchFinished:(TIPInputElement *)foundElement;
@end

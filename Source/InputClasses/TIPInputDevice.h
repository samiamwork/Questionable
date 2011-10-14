//
//  TIPInputDevice.h
//  HIDInputUtils
//
//  Created by Nur Monson on 11/15/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TIPInputElement.h"

@class TIPInputDevice;
@protocol TIPInputDeviceDelegate
- (void)TIPInputDevice:(TIPInputDevice*)theDevice buttonPressed:(TIPInputElement*)theElement;
- (void)TIPInputDevice:(TIPInputDevice*)theDevice buttonReleased:(TIPInputElement*)theElement;
@end


@interface TIPInputDevice : NSObject {
	IOHIDDeviceRef             _device;
	id<TIPInputDeviceDelegate> _delegate;

	NSMutableDictionary* _elements;
	
	// properties
	long locationID;
	long vendorID;
	long productID;
	long version;
	NSString *manufacturer;
	NSString *product;
	NSString *serial;
}

+ (id)deviceWithDeviceRef:(IOHIDDeviceRef)theDevice;
- (id)initWithDeviceRef:(IOHIDDeviceRef)theDevice;

- (long)locationID;
- (IOHIDDeviceRef)deviceRef;
- (void)setDelegate:(id<TIPInputDeviceDelegate>)delegate;
@end

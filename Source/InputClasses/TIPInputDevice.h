//
//  TIPInputDevice.h
//  HIDInputUtils
//
//  Created by Nur Monson on 11/15/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TIPInputElement.h"

@interface TIPInputDevice : NSObject {
	IOHIDDeviceInterface **deviceInterface;
	//NSMutableDictionary *description;
	
	NSMutableArray *elements;
	
	// properties
	long locationID;
	long vendorID;
	long productID;
	long version;
	NSString *manufacturer;
	NSString *product;
	NSString *serial;
}

+ (id)deviceWithIOObject:(io_object_t)ioObject exclusive:(BOOL)getExclusive;

- (void)connectWithIOObject:(io_object_t)ioObject exclusive:(BOOL)getExclusive;
- (NSArray *)elements;
- (long)locationID;

- (IOHIDDeviceInterface **)deviceInterface;

- (TIPInputElement *)getAnyElementWithTimeout:(NSTimeInterval)timeout;
@end

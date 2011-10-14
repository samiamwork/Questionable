//
//  TIPInputElement.h
//  HIDInputUtils
//
//  Created by Nur Monson on 11/16/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/hid/IOHIDLib.h>
#import <IOKit/hid/IOHIDUsageTables.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/hid/IOHIDLib.h>

@class TIPInputDevice;

@interface TIPInputElement : NSObject {
	IOHIDElementRef _element;
	TIPInputDevice* _device;
}

+ (id)elementWithElementRef:(IOHIDElementRef)theElement device:(TIPInputDevice*)device;
- (id)initWithElementRef:(IOHIDElementRef)theElement device:(TIPInputDevice*)device;
- (TIPInputDevice*)device;
@end

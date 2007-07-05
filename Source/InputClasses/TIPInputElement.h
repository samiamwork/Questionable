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

@interface TIPInputElement : NSObject {
	IOHIDElementCookie cookie;
	IOHIDElementType type;
	long usagePage;
	long usage;
	long min;
	long max;
	
	// for calibration
	long scaledMin;
	long scaledMax;
	
	long size;
	BOOL isRelative;
	BOOL isWrapping;
	BOOL isNonLinear;
	//BOOL hasPreferredState;
	BOOL hasNullState;
	
	long referenceValue;
	
	NSString *name;
	NSMutableArray *collectionElements;
	id device;
}

+ (id)elementWithDictionary:(NSDictionary *)description device:(id)aDevice;

- (NSString *)name;
- (void)setName:(NSString *)newName;
- (id)device;
- (void)setDevice:(id)newDevice;

- (long)usagePage;
- (long)usage;
- (IOHIDElementType)type;

- (long)getValue;
- (void)setReferenceValue;
- (TIPInputElement *)isDifferentThanReference;

- (NSArray *)collectionElements;
@end

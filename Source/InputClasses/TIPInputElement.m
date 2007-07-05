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

- (id)init
{
	if( (self = [super init]) ) {
		cookie = 0;
		type = 0;
		usagePage = 0;
		usage = 0;
		min = 0;
		max = 0;
		
		scaledMin = 0;
		scaledMax = 0;
		
		size = 0;
		
		isRelative = NO;
		isWrapping = NO;
		isNonLinear = NO;
		//hasPreferredState = NO;
		hasNullState = NO;
		
		name = @"not initaized";
		collectionElements = nil;
		device = nil;
	}

	return self;
}

- (void)dealloc
{
	[super dealloc];

	[name release];
}

+ (id)elementWithDictionary:(NSDictionary *)description device:(id)aDevice
{
	TIPInputElement *newElement = [[[TIPInputElement alloc] init] autorelease];
	NSNumber *num;
	
	[newElement setDevice:aDevice];
	
	num = [description valueForKey:@kIOHIDElementCookieKey];
	if( num )
		newElement->cookie = (IOHIDElementCookie)[num longValue];
	
	num = [description valueForKey:@kIOHIDElementTypeKey];
	if( num ) {
		newElement->type = [num unsignedLongValue];
		
		switch (newElement->type) {
		case kIOHIDElementTypeInput_Misc:
			[newElement setName:@"Misc. Input"];
			break;
		case kIOHIDElementTypeInput_Button:
			[newElement setName:@"Button"];
			break;
		case kIOHIDElementTypeInput_Axis:
			[newElement setName:@"Axis"];
			break;
		case kIOHIDElementTypeInput_ScanCodes:
			[newElement setName:@"Scan Codes"];
			break;
		case kIOHIDElementTypeOutput:
			[newElement setName:@"Output"];
			break;
		case kIOHIDElementTypeFeature:
			// we  really don't care to deal with these kinds
			//[newElement release];
			//return nil;
			[newElement setName:@"Feature"];
			break;
		case kIOHIDElementTypeCollection:
			newElement->collectionElements = [[NSMutableArray alloc] init];
			NSArray *elements = [description valueForKey:@kIOHIDElementKey];
			NSEnumerator *elementEnumerator = [elements objectEnumerator];
			NSDictionary *elementDict;
			
			while( (elementDict = [elementEnumerator nextObject]) ) {
				TIPInputElement *newCollectionElement = [TIPInputElement elementWithDictionary:elementDict device:aDevice];
				if( [newCollectionElement usage] != -1 && [newCollectionElement type] != kIOHIDElementTypeInput_Axis )
					[newElement->collectionElements addObject:newCollectionElement];
			}
				
			break;
		default:
			[newElement release];
			return nil;
			break;
		}
	}
	
	num = [description valueForKey:@kIOHIDElementUsagePageKey];
	if( num )
		newElement->usagePage = [num longValue];
	
	num = [description valueForKey:@kIOHIDElementUsageKey];
	if( num )
		newElement->usage = [num longValue];
	
	num = [description valueForKey:@kIOHIDElementMinKey];
	if( num )
		newElement->min = [num longValue];
	
	num = [description valueForKey:@kIOHIDElementMaxKey];
	if( num )
		newElement->max = [num longValue];
	
	num = [description valueForKey:@kIOHIDElementSizeKey];
	if( num )
		newElement->size = [num longValue];
	
	num = [description valueForKey:@kIOHIDElementIsRelativeKey];
	if( num )
		newElement->isRelative = [num boolValue];
	
	num = [description valueForKey:@kIOHIDElementIsWrappingKey];
	if( num )
		newElement->isWrapping = [num boolValue];
	
	num = [description valueForKey:@kIOHIDElementIsNonLinearKey];
	if( num )
		newElement->isNonLinear = [num boolValue];
	
	num = [description valueForKey:@kIOHIDElementHasNullStateKey];
	if( num )
		newElement->hasNullState = [num boolValue];
	
	return newElement;
}

- (NSString *)name
{
	return name;
}
- (void)setName:(NSString *)newName
{
	if( newName == name )
		return;
	
	[name release];
	name = [newName retain];
}
- (id)device
{
	return device;
}
- (void)setDevice:(id)newDevice
{
	if( newDevice == device )
		return;
	
	device = newDevice;
}

- (long)usagePage
{
	return usagePage;
}
- (long)usage
{
	return usage;
}

- (IOHIDElementType)type
{
	return type;
}

- (long)getValue
{
	IOReturn result = kIOReturnBadArgument;
    IOHIDEventStruct hidEvent;
	
	hidEvent.value = 0;
    hidEvent.longValueSize = 0;
	hidEvent.longValue = 0;
	
	//TODO: remove assumptions of valid device
	IOHIDDeviceInterface **deviceInterface = [(TIPInputDevice*)device deviceInterface];
	
	//If we're a feature type then we should query instead of get
	if( type == kIOHIDElementTypeFeature ) {
		result = (*deviceInterface)->queryElementValue( deviceInterface, cookie, &hidEvent, 0, 0, 0, 0 );
		if( result == kIOReturnUnsupported ) {
			// try with "get" instead
		} else if( result != kIOReturnSuccess ) {
			//TODO: find out what this error is: 0xe000404F (kIOUSBPipeStalled)
			//printf("error with query: %02x\n", result);
			//printf("Could not query element value! (cookie = %d, usage = %d, usagePage = %d)\n", (int)cookie, (int)usage, (int)usagePage);
			return 0;
		} else
			return hidEvent.value;
		 
		return 0;
	} else if( type == kIOHIDElementTypeCollection )
		return 0;

	result = (*deviceInterface)->getElementValue( deviceInterface, cookie, &hidEvent );
	if( result != kIOReturnSuccess ) {
		printf("Could not Get element value! (cookie = %d, usage = %d, usagePage = %d)\n", (int)cookie, (int)usage, (int)usagePage);
		return 0;
	}
	
	return hidEvent.value;
}

//TODO: if a device has a default state then use that as the reference value
- (void)setReferenceValue
{
	if( type == kIOHIDElementTypeCollection ) {
		NSEnumerator *elementEnumerator = [collectionElements objectEnumerator];
		TIPInputElement *anElement;
		while( (anElement = [elementEnumerator nextObject]) )
			[anElement setReferenceValue];
	} else
		referenceValue = [self getValue];
}

- (TIPInputElement *)isDifferentThanReference
{
	if( type == kIOHIDElementTypeCollection ) {
		
		TIPInputElement *different = nil;
		NSEnumerator *elementEnumerator = [collectionElements objectEnumerator];
		TIPInputElement *anElement;
		while( different == nil && (anElement = [elementEnumerator nextObject]) )
			different = [anElement isDifferentThanReference];
		
		return different;
	} else {
		long delta = (float)(max - min)*0.1;
		long value = [self getValue];
		
		if( (referenceValue + delta) < value || (referenceValue - delta) > value )
			return self;
		
		return nil;
	}
	
	return nil;
}

- (NSArray *)collectionElements
{
	return collectionElements;
}
@end

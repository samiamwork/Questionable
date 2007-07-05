//
//  TIPInputDevice.m
//  HIDInputUtils
//
//  Created by Nur Monson on 11/15/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TIPInputDevice.h"


@implementation TIPInputDevice

- (id)init
{
	if( (self = [super init]) ) {
		deviceInterface = NULL;
		//description = [[NSMutableDictionary alloc] init];
		elements = [[NSMutableArray alloc] init];
		
		// properties
		locationID = 0;
		vendorID = 0;
		productID = 0;
		version = 0;
		manufacturer = @"manufacturer";
		product = @"product";
		serial = @"serial";
	}

	return self;
}

- (void)dealloc
{
	[elements removeAllObjects];
	
	// close device interface
	if( deviceInterface != NULL )
		(*deviceInterface)->close( deviceInterface );
	
	[super dealloc];
}

+ (id)deviceWithIOObject:(io_object_t)ioObject exclusive:(BOOL)getExclusive
{
	if( ioObject == IO_OBJECT_NULL )
		return nil;
	
	TIPInputDevice *newDevice = [[[TIPInputDevice alloc] init] autorelease];
	[newDevice connectWithIOObject:ioObject exclusive:(BOOL)getExclusive];
	
	return newDevice;
}

- (void)connectWithIOObject:(io_object_t)ioObject exclusive:(BOOL)getExclusive
{
	IOReturn result = kIOReturnSuccess;
	HRESULT pluginResult = S_OK;
	SInt32 score = 0;
	IOCFPlugInInterface **pluginInterface = NULL;
	
	//close it if we already have one assigned
	if( deviceInterface != NULL ) {
		(*deviceInterface)->close( deviceInterface );
		deviceInterface = NULL;
		[elements removeAllObjects];
	}
	
	// if we were just passed NULL then we don't want to do anything other than
	// close any previously connected objects
	if( ioObject == IO_OBJECT_NULL )
		return;
	
	//[description removeAllObjects];
	NSMutableDictionary *description;
	result = IORegistryEntryCreateCFProperties( ioObject, (CFMutableDictionaryRef *)&description, kCFAllocatorDefault, kNilOptions);
	if( result != kIOReturnSuccess ) {
		printf("Could not get device description!\n");
		return;
	}
	//[description writeToFile:@"/Users/samiam/Desktop/deviceDescription.plist" atomically:YES];
	NSNumber *num;
	num = [description valueForKey:@kIOHIDLocationIDKey];
	if( num )
		locationID = [num longValue];
	
	num = [description valueForKey:@kIOHIDVendorIDKey];
	if( num )
		vendorID = [num longValue];
	
	num = [description valueForKey:@kIOHIDProductIDKey];
	if( num )
		productID = [num longValue];
	
	num = [description valueForKey:@kIOHIDVersionNumberKey];
	if( num )
		version = [num longValue];
	
	NSString *string;
	string = [description valueForKey:@kIOHIDManufacturerKey];
	if( string ) {
		[manufacturer release];
		manufacturer = [[NSString alloc] initWithString:string];
	}
	
	string = [description valueForKey:@kIOHIDProductKey];
	if( string ) {
		[product release];
		product = [[NSString alloc] initWithString:string];
	}
	
	string = [description valueForKey:@kIOHIDSerialNumberKey];
	if( string ) {
		[serial release];
		serial  = [[NSString alloc] initWithString:string];
	}
	
	// now gather the elements
	NSArray *descriptionElements = [description valueForKey:@kIOHIDElementKey];
	if( descriptionElements ) {
		NSEnumerator *elementEnumerator = [descriptionElements objectEnumerator];
		NSDictionary *elementDescription;
		while( (elementDescription = [elementEnumerator nextObject]) ) {
			TIPInputElement *newElement = [TIPInputElement elementWithDictionary:elementDescription device:self];
			if( [newElement usage] != -1 && [newElement type] != kIOHIDElementTypeInput_Axis )
				[elements addObject:newElement];
		}
	}
	[description release];
	
	result = IOCreatePlugInInterfaceForService( ioObject,kIOHIDDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &pluginInterface, &score );
	if( result != kIOReturnSuccess ) {
		printf("Could not get interface for IO object\n");
		return;
	}
	
	pluginResult = (*pluginInterface)->QueryInterface( pluginInterface, CFUUIDGetUUIDBytes(kIOHIDDeviceInterfaceID), (void *)&deviceInterface );
	if( pluginResult != S_OK ) {
		printf("Could not get device interface!\n");
		return;
	}
	// don't need it anymore
	IODestroyPlugInInterface( pluginInterface );
	// open it for access
	// kIOHIDOptionsTypeSeizeDevice
	if( getExclusive )
		result = (*deviceInterface)->open( deviceInterface, kIOHIDOptionsTypeSeizeDevice );
	else
		result = (*deviceInterface)->open( deviceInterface, 0 );
	if( result != S_OK ) {
		printf("Could not open device for access!\n");
		return;
	}
}

- (TIPInputElement *)getAnyElementWithTimeout:(NSTimeInterval)timeout
{
	NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
	
	NSEnumerator *elementEnumerator = [elements objectEnumerator];
	TIPInputElement *anElement;
	TIPInputElement *differentElement = nil;
	
	while( (anElement = [elementEnumerator nextObject]) )
		[anElement setReferenceValue];
	
	while( [NSDate timeIntervalSinceReferenceDate] - startTime < timeout ) {
		elementEnumerator = [elements objectEnumerator];
		
		while( (anElement = [elementEnumerator nextObject]) ) {
			differentElement = [anElement isDifferentThanReference];
			if( differentElement != nil )
				return differentElement;
		}
	}
	
	return differentElement;
}

- (NSArray *)elements
{
	return elements;
}
- (long)locationID
{
	return locationID;
}

- (IOHIDDeviceInterface **)deviceInterface
{
	return deviceInterface;
}

- (BOOL)isEqual:(id)anObject
{
	if( [anObject hash] == [self hash] )
		return YES;
	
	return NO;
}
- (unsigned)hash
{
	return (unsigned)locationID;
}
@end

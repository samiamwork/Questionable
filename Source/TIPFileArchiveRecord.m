//
//  TIPFileArchiveRecord.m
//  TriviaOutlineView
//
//  Created by Nur Monson on 2/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TIPFileArchiveRecord.h"

@interface NSObject (private)
- (void)errorWhileCopyingFrom:(NSString *)aPath withContext:(void *)aContext;
@end

@implementation TIPFileArchiveRecord

- (id)init
{
	if( (self = [super init]) ) {
		theDelegate = nil;
		theContext = NULL;
		
		theToPath = @"";
		theFromPath = @"";
		theFileSize = 0;
				
		theFileOperation = NULL;
	}

	return self;
}

- (void)dealloc
{
	[theToPath release];
	[theFromPath release];

	[super dealloc];
}

+ (id)archiveRecordFrom:(NSString *)aFromPath to:(NSString *)aToPath withDelegate:(id)delegate context:(void *)context
{
	TIPFileArchiveRecord *newArchiveRecord = [[TIPFileArchiveRecord alloc] init];
	
	[newArchiveRecord setFromPath:aFromPath];
	[newArchiveRecord setToPath:aToPath];
	[newArchiveRecord setDelegate:delegate];
	[newArchiveRecord setContext:context];
	
	return [newArchiveRecord autorelease];
}

- (void)informDelegateOfError
{
	if( theDelegate != nil && [theDelegate respondsToSelector:@selector(errorWhileCopyingFrom:withContext:)] )
		[theDelegate errorWhileCopyingFrom:theFromPath withContext:theContext];
}

#pragma mark Accessor Methods

- (NSString *)toPath
{
	return theToPath;
}
- (void)setToPath:(NSString *)newToPath
{
	if( newToPath == theToPath ) return;
	
	[theToPath release];
	theToPath = [newToPath retain];
	
	FSPathMakeRef((UInt8*)[[theToPath stringByDeletingLastPathComponent] fileSystemRepresentation], &theDestinationDir,NULL);
}

- (NSString *)fromPath
{
	return theFromPath;
}
- (void)setFromPath:(NSString *)newFromPath
{
	if( newFromPath == theFromPath ) return;
	
	[theFromPath release];
	theFromPath = [newFromPath retain];

	FSPathMakeRef((UInt8*)[theFromPath fileSystemRepresentation], &theSourceFile, NULL);

	NSError* err;
	NSDictionary *fileStats = [[NSFileManager defaultManager] attributesOfItemAtPath:theFromPath error:&err];
	if( fileStats != nil )
		theFileSize = [[fileStats valueForKey:NSFileSize] unsignedLongLongValue];
}

- (id)delegate
{
	return theDelegate;
}
- (void)setDelegate:(id)newDelegate
{
	theDelegate = newDelegate;
}

- (void *)context
{
	return theContext;
}
- (void)setContext:(void *)newContext
{
	theContext = newContext;
}

- (unsigned long long)fileSize
{
	return theFileSize;
}

- (unsigned long long)bytesLeftToCopy
{
	if( theFileOperation == NULL )
		return 0;
	
	unsigned long long bytesLeft = 0;
	NSDictionary *copyStatus;
	OSStatus err;
	
	FSFileOperationCopyStatus( theFileOperation,NULL, NULL, &err, (CFDictionaryRef *)&copyStatus, NULL );
	
	bytesLeft = [[copyStatus valueForKey:(NSString *)kFSOperationBytesRemainingKey] unsignedLongLongValue];
	
	if( bytesLeft == 0 ) {
		CFRelease( theFileOperation );
		theFileOperation = NULL;
	}
	
	return bytesLeft;
}

- (void)startCopyAsync
{
	if( theFileOperation != NULL )
		CFRelease( theFileOperation );
	theFileOperation = FSFileOperationCreate(NULL);
	//FSFileOperationScheduleWithRunLoop(theFileOperation, [[NSRunLoop currentRunLoop] getCFRunLoop], (CFStringRef)NSDefaultRunLoopMode);
	
	FSCopyObjectAsync( theFileOperation, &theSourceFile, &theDestinationDir,
					  (CFStringRef)[theToPath lastPathComponent],
					  kFSFileOperationOverwrite,
					  NULL, 0.5 , NULL);	
}

- (void)stopCopyAsync
{
	if( theFileOperation == NULL )
		return;
	
	FSFileOperationCancel(theFileOperation);
	CFRelease(theFileOperation);
	theFileOperation = NULL;
}
@end

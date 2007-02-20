//
//  TIPFileArchiveRecord.h
//  TriviaOutlineView
//
//  Created by Nur Monson on 2/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TIPFileArchiveRecord : NSObject {
	NSString *theToPath;
	NSString *theFromPath;
	
	unsigned long long theFileSize;
	void *theContext;
	id theDelegate;
	
	FSFileOperationRef theFileOperation;
	FSRef theSourceFile;
	FSRef theDestinationDir;
}

+ (id)archiveRecordFrom:(NSString *)aFromPath to:(NSString *)aToPath withDelegate:(id)delegate context:(void *)context;

- (void)informDelegateOfError;

- (NSString *)toPath;
- (void)setToPath:(NSString *)newToPath;

- (NSString *)fromPath;
- (void)setFromPath:(NSString *)newFromPath;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (void *)context;
- (void)setContext:(void *)newContext;

- (unsigned long long)fileSize;

// if this returns a zero then it will clean up the copy
// assuming it's done.
- (unsigned long long)bytesLeftToCopy;

- (void)startCopyAsync;
- (void)stopCopyAsync;
@end

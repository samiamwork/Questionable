//
//  TIPFileArchiver.m
//  TriviaOutlineView
//
//  Created by Nur Monson on 1/29/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TIPFileArchiver.h"

/*
 FileArchiver is still fairly brittle. If an error happens in copying we want the
 objects we're archiving for to know about it but instead they keep the "new"
 filename that is now invalid, thereby totally screwing up any further save attem
 pts and ruining the file.
 */

@implementation TIPFileArchiver

- (id)init
{
	if( (self = [super init]) ) {
		theArchivePath = nil;
		theFilesToCopy = nil;
		theUsedFilenames = [[NSMutableArray alloc] init];
		
		theSizeToCopyInBytes = 0;
	}

	return self;
}

- (id)initWithDirectory:(NSString *)aDirectory
{
	if( (self = [self init]) ) {

		BOOL isDirectory;
		if( [[NSFileManager defaultManager] fileExistsAtPath:aDirectory isDirectory:&isDirectory] && isDirectory) {
			theUsedFilenames = [[NSMutableArray alloc] initWithArray:[[NSFileManager defaultManager] directoryContentsAtPath:aDirectory]];
		} else
			theUsedFilenames = [[NSMutableArray alloc] init];
		
		theArchivePath = [[NSString alloc] initWithString:[aDirectory stringByStandardizingPath]];
		theFilesToCopy = [[NSMutableArray alloc] init];
		
		existingFiles = [[NSMutableArray alloc] initWithArray:theUsedFilenames];
	}
	
	return self;
}

- (void)dealloc
{
	[theArchivePath release];
	[theUsedFilenames release];
	[theFilesToCopy release];
	[existingFiles release];

	[super dealloc];
}

+ (id)archiverWithDirectory:(NSString *)aDirectory
{
	TIPFileArchiver *newArchiver = [[TIPFileArchiver alloc] initWithDirectory:aDirectory];
	
	return [newArchiver autorelease];
}

- (NSString *)archivePath
{
	return theArchivePath;
}

// should check to see if the same file has already bee copied in
- (NSString *)archiveFile:(NSString *)filePath withDelegate:(id)aDelegate context:(void *)aContext
{

	NSString *cleanPath = [filePath stringByStandardizingPath];

	//check to see if the filePath is already pointing to a file in the archive
	NSString *fileName = [cleanPath lastPathComponent];
	NSString *fileDirectory = [cleanPath stringByDeletingLastPathComponent];

	// already in the archive, no need to copy
	if( [fileDirectory isEqualToString:theArchivePath] ) {
		[existingFiles removeObject:fileName];
		return filePath;
	}

	//give it a new name if there's already one with that name in the archive.
	NSString *availableFileName = fileName;
	NSString *fileExtension = [availableFileName pathExtension];
	NSString *fileBaseName = [availableFileName stringByDeletingPathExtension];
	unsigned fileNumber = 2;
	while( [theUsedFilenames containsObject:availableFileName] ) {
		availableFileName = [NSString stringWithFormat:@"%@ %03d.%@",fileBaseName,fileNumber,fileExtension];
		fileNumber++;
	}
	[theUsedFilenames addObject:availableFileName];

	NSString *newDestinationPath = [theArchivePath stringByAppendingPathComponent:availableFileName];
	TIPFileArchiveRecord *aRecord = [TIPFileArchiveRecord archiveRecordFrom:cleanPath to:newDestinationPath withDelegate:aDelegate context:aContext];
	[theFilesToCopy addObject:aRecord];
	
	theSizeToCopyInBytes += [aRecord fileSize];
	
	[existingFiles removeObject:availableFileName];
	return newDestinationPath;
}

- (void)commitArchive
{
	// if directory doesn't exist or is a file, create it.
	BOOL isDirectory;
	BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:theArchivePath isDirectory:&isDirectory];
	if( doesExist && !isDirectory )
		[[NSFileManager defaultManager] removeFileAtPath:theArchivePath handler:NULL];
	if( !doesExist )
		[[NSFileManager defaultManager] createDirectoryAtPath:theArchivePath attributes:nil];

	// first delete files so that we don't use up more space than we need to
	NSEnumerator *fileEnumerator = [existingFiles objectEnumerator];
	NSString *fileToDelete;
	while( (fileToDelete = [fileEnumerator nextObject]) )
		[[NSFileManager defaultManager] removeFileAtPath:[theArchivePath stringByAppendingPathComponent:fileToDelete] handler:NULL];
	
	if( [theFilesToCopy count] == 0 )
		return;

	// if the files to copy total less than X megs then don't both with the async
	// copy. The progress dialog would just look silly flashing on the screen.
	if( theSizeToCopyInBytes < 10<<20 )
		[self syncArchive];
	else
		[self asyncArchive];
	
	//empty and reset arrays to prepare for another run...maybe
	[existingFiles removeAllObjects];
	[existingFiles addObjectsFromArray:[[NSFileManager defaultManager] directoryContentsAtPath:theArchivePath]];
	
	theSizeToCopyInBytes = 0;
}

- (void)asyncArchive
{
	[self copyNextRecord];
	theCopyStatusTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(statusTimerFired:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:theCopyStatusTimer forMode:NSModalPanelRunLoopMode];
	
	theBytesCopied = 0;	
	theProgressController = [[SaveProgressController alloc] init];
	[theProgressController setCancelDelegate:self];
	[theProgressController setMaxBytes:theSizeToCopyInBytes];
	[theProgressController beginModalStatus];
	
	[theProgressController release];
}

- (void)syncArchive
{
	NSEnumerator *fileEnumerator = [theFilesToCopy objectEnumerator];
	TIPFileArchiveRecord *aRecord;
	while( (aRecord = [fileEnumerator nextObject]) )
		[[NSFileManager defaultManager] copyPath:[aRecord fromPath] toPath:[aRecord toPath] handler:NULL];
	
	[theFilesToCopy removeAllObjects];
}

// delegate method for the save progress window controller
- (void)saveCanceled
{
	[theCopyStatusTimer invalidate];
	[theCurrentlyCopyingRecord stopCopyAsync];
	[theProgressController endModalStatus];
	// first tell all delegates that they did not copy successfully
	[theFilesToCopy makeObjectsPerformSelector:@selector(informDelegateOfError)];
}

- (void)statusTimerFired:(NSTimer *)aTimer
{
	unsigned long long bytesTotal = [theCurrentlyCopyingRecord fileSize];
	unsigned long long bytesLeft = [theCurrentlyCopyingRecord bytesLeftToCopy];
	
	[theProgressController setBytesDone:theBytesCopied + bytesTotal - bytesLeft];
	
	if( bytesLeft == 0 ) {
		theBytesCopied += bytesTotal;
		[self copyNextRecord];
	}
}

- (void)copyNextRecord
{
	[theFilesToCopy removeObject:theCurrentlyCopyingRecord];
	if( [theFilesToCopy count] == 0 ) {
		
		[theProgressController endModalStatus];
		[theCopyStatusTimer invalidate];
		
		return;
	}
	
	theCurrentlyCopyingRecord = [theFilesToCopy objectAtIndex:0];
	[theCurrentlyCopyingRecord startCopyAsync];
}

@end

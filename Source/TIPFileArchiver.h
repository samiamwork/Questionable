//
//  TIPFileArchiver.h
//  TriviaOutlineView
//
//  Created by Nur Monson on 1/29/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TIPFileArchiveRecord.h"
#import "SaveProgressController.h"


@interface TIPFileArchiver : NSObject {
	NSString *theArchivePath;
	
	NSMutableArray *theFilesToCopy;
	unsigned long long theSizeToCopyInBytes;
	unsigned long long theBytesCopied;
	NSMutableArray *theUsedFilenames;
	
	NSMutableArray *existingFiles;
		
	NSTimer *theCopyStatusTimer;
	TIPFileArchiveRecord *theCurrentlyCopyingRecord;
	SaveProgressController *theProgressController;
}

+ (id)archiverWithDirectory:(NSString *)aDirectory;
- (id)initWithDirectory:(NSString *)aDirectory;
- (NSString *)archivePath;

// if file does not need to be moved it will return nil, otherwise it will return
// the path that it will copy the file to.
- (NSString *)archiveFile:(NSString *)filePath withDelegate:(id)aDelegate context:(void *)aContext;
- (void)commitArchive;

- (void)asyncArchive;
- (void)syncArchive;
- (void)copyNextRecord;
@end

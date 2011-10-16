//
//  TriviaQuestionDocument.m
//  TriviaOutlineView
//
//  Created by Nur Monson on 1/31/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TriviaQuestionDocument.h"


@implementation TriviaQuestionDocument

- (id)init
{
	if( (self = [super init]) ) {
		theBoards = [[NSMutableArray alloc] init];
	}

	return self;
}

- (void)dealloc
{
	NSEnumerator *boardEnumerator = [theBoards objectEnumerator];
	TriviaBoard *aBoard;
	while( (aBoard = [boardEnumerator nextObject]) ) {
		//printf("retain count = %d\n", [aBoard retainCount]);
		[aBoard removeObserver:self forKeyPath:@"anyPropertyChanged"];
	}
	
	[theBoards release];

	[super dealloc];
}


- (void)makeWindowControllers
{
	// do nothing because we have no windows we control. We're just used for managing the document.
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	if( ![absoluteURL isFileURL] ) {
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Not a valid file path.",@"Not a valid file path."),NSLocalizedDescriptionKey,nil];
		*outError = [NSError errorWithDomain:@"TriviaQuestionDomain" code:1 userInfo:errorDict];
		return NO;
	}
	
	NSString *path = [absoluteURL path];
	
	NSString *filename = [path stringByAppendingPathComponent:@"trivia.qinfo"];
	NSDictionary *triviaDictionary = [NSDictionary dictionaryWithContentsOfFile:filename];
	if( triviaDictionary == nil ) {
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Could not open file.",@"Could not open file."),NSLocalizedDescriptionKey,nil];
		*outError = [NSError errorWithDomain:@"TriviaQuestionDomain" code:1 userInfo:errorDict];
		return NO;
	}
	
	[theBoards removeAllObjects];
	
	NSArray *boardDictionaries = [triviaDictionary valueForKey:@"boards"];
	NSEnumerator *boardEnumerator = [boardDictionaries objectEnumerator];
	NSDictionary *aBoardDictionary;
	while( (aBoardDictionary = [boardEnumerator nextObject]) ) {
		TriviaBoard *aBoard = [TriviaBoard boardFromDictionary:aBoardDictionary inPath:[path stringByAppendingPathComponent:@"media"]];
		//[theBoards addObject:aBoard];
		[self addBoard:aBoard];
	}
	
	[self setFileURL:absoluteURL];
	return YES;
}

// because this document is a bundle type that can grow very large and we don't want to copy files
// all over the place we're overriding this to stop the backup-and-copy method it normally uses.
- (BOOL)writeSafelyToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError
{
	return [self writeToURL:absoluteURL ofType:typeName error:outError];
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	if( ![absoluteURL isFileURL] ) {
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Not a valid file path",@"Not a valid file path."),NSLocalizedDescriptionKey,nil];
		*outError = [NSError errorWithDomain:@"TriviaQuestionFileDomain" code:1 userInfo:errorDict];
		return NO;
	}
	
	NSString *filename = [absoluteURL path];
	NSString *locatedInDir = [filename stringByDeletingLastPathComponent];
	if( ![[NSFileManager defaultManager] isWritableFileAtPath:locatedInDir] ) {
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:nil];
		*outError = [NSError errorWithDomain:@"TriviaQuestionFileDomain" code:2 userInfo:errorDict];
		return NO;
	}
	
	//if our directory doesn't exist then create it, or delete it if it's a file.
	NSError* err;
	BOOL isDirectory;
	BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:&isDirectory];
	if( doesExist && !isDirectory )
		[[NSFileManager defaultManager] removeItemAtPath:filename error:&err];
	if( !doesExist )
		[[NSFileManager defaultManager] createDirectoryAtPath:filename withIntermediateDirectories:YES attributes:nil error:&err];
	
	NSString *mediaDirectory = [filename stringByAppendingPathComponent:@"media"];
	TIPFileArchiver *fileArchiver = [[TIPFileArchiver alloc] initWithDirectory:mediaDirectory];
	
	NSMutableArray *encodedBoards = [NSMutableArray array];
	NSEnumerator *boardEnumerator = [theBoards objectEnumerator];
	TriviaBoard *aBoard;
	while( (aBoard = [boardEnumerator nextObject]) ) {
		[encodedBoards addObject:[aBoard encodeAsMutableDictionaryWithArchiver:fileArchiver]];
	}
	
	NSString *infoFilename = [filename stringByAppendingPathComponent:@"trivia.qinfo"];
	[[NSDictionary dictionaryWithObject:encodedBoards forKey:@"boards"] writeToFile:infoFilename atomically:YES];
	
	[fileArchiver commitArchive];
	[fileArchiver release];
	
	return YES;
}

- (NSArray *)writableTypesForSaveOperation:(NSSaveOperationType)saveOperation
{
	return [NSArray arrayWithObject:@"TriviaDocument"];
}

- (NSArray *)boards
{
	return theBoards;
}
- (void)setBoards:(NSArray *)newBoards
{
	if( newBoards == theBoards )
		return;
	
	[theBoards release];
	theBoards = [newBoards mutableCopy];
}
- (void)addBoard:(TriviaBoard *)aBoard;
{
	if( aBoard == nil )
		return;
	
	[aBoard addObserver:self forKeyPath:@"anyPropertyChanged" options:NSKeyValueObservingOptionNew context:nil];
	[theBoards addObject:aBoard];
}
- (void)removeBoard:(TriviaBoard *)aBoard
{
	if( aBoard == nil )
		return;
	
	[aBoard removeObserver:self forKeyPath:@"NSKeyValueObservingOptionNew"];
	[theBoards removeObject:aBoard];
}

// returns false if canceled
- (BOOL)promptIfUnsavedChanges
{
	if( ![self isDocumentEdited] )
		return YES;
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:NSLocalizedString(@"Save", @"Save")];
	NSButton *alertButton = [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel")];
	[alertButton setKeyEquivalent:@"\E"];
	alertButton = [alert addButtonWithTitle:NSLocalizedString(@"Don't Save", @"Don't Save")];
	[alertButton setKeyEquivalent:@"d"];
	[alertButton setKeyEquivalentModifierMask:NSCommandKeyMask];
	[alert setMessageText:@"These questions have unsaved changes. Would you like to save?"];
	[alert setAlertStyle:NSWarningAlertStyle];
	
	int result = [alert runModal];
	switch( result ) {
		case NSAlertFirstButtonReturn:
			[self saveDocument:nil];
			break;
		case NSAlertThirdButtonReturn:
			// do nothing (i.e. don't save).
			break;
		case NSAlertSecondButtonReturn:
		default:
			// canceled
			return NO;
			break;
	}
	
	return YES;
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if( ![keyPath isEqualToString:@"anyPropertyChanged"] )
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	[self updateChangeCount:NSChangeDone];
}

@end

//
//  TIPMovie.m
//  TriviaOutlineView
//
//  Created by Nur Monson on 1/30/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TIPMovie.h"


@implementation TIPMovie

- (id)initWithPasteboard:(NSPasteboard *)pasteboard error:(NSError **)errorPtr
{
	if( (self = [super initWithPasteboard:pasteboard error:errorPtr]) ) {
		
		NSString *filename;
		NSString *availableType = [pasteboard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]];
		if( availableType == nil ) {
			[self release];
			return nil;
		}
		filename = [(NSArray *)[pasteboard propertyListForType:NSFilenamesPboardType] objectAtIndex:0];
		
		[self setPathToFile:filename];
	}
	
	return self;
}

- (NSString *)pathToFile
{
	return thePathToFile;
}
- (void)setPathToFile:(NSString *)newPathToFile
{
	if( newPathToFile == thePathToFile )
		return;
	
	[thePathToFile release];
	thePathToFile = [newPathToFile retain];
}
@end

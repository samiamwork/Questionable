//
//  QuestionableDelegate.m
//  Questionable
//
//  Created by Nur Monson on 2/12/07.
//  Copyright theidiotproject 2007. All rights reserved.
//

#import "QuestionableDelegate.h"
#import "NSApplicationExtensions.h"
#import "TriviaQuestionDocument.h"

@implementation QuestionableDelegate

+ (void)initialize
{
	BoolToStatusImageTransformer *imageTransformer = [[BoolToStatusImageTransformer alloc] init];
	[NSValueTransformer setValueTransformer:imageTransformer forName:@"BoolToStatusImageTransformer"];
	[imageTransformer release];
	
	BoolToStatusStringTransformer *stringTransformer = [[BoolToStatusStringTransformer alloc] init];
	[NSValueTransformer setValueTransformer:stringTransformer forName:@"BoolToStatusStringTransformer"];
	[stringTransformer release];
	
	//set user defaults
	NSMutableDictionary *defaultDict = [NSMutableDictionary dictionary];
	
	[defaultDict setValue:[NSNumber numberWithInt:15] forKey:@"lengthOfQuestion"];
	[defaultDict setValue:[NSNumber numberWithInt:30] forKey:@"lengthOfGame"];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultDict];
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultDict];
}

- (void) awakeFromNib
{
	
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	if( [[filename pathExtension] isEqualToString:@"questionablelicense"] ) {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"No need to register. This app is free now."];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert runModal];
		
		[alert release];
		
		return YES;
	} else
		return [viewController openGameFile:filename];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	if( ![[viewController document] promptIfUnsavedChanges] )
		return NSTerminateCancel;
	return NSTerminateNow;
}

@end

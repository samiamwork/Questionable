//
//  QuestionableDelegate.m
//  Questionable
//
//  Created by Nur Monson on 2/12/07.
//  Copyright theidiotproject 2007. All rights reserved.
//

#import "QuestionableDelegate.h"


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
	return [viewController openGameFile:filename];
}

@end

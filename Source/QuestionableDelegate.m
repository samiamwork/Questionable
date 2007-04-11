//
//  QuestionableDelegate.m
//  Questionable
//
//  Created by Nur Monson on 2/12/07.
//  Copyright theidiotproject 2007. All rights reserved.
//

#import "QuestionableDelegate.h"
#import "NSApplicationExtensions.h"
#import "AquaticPrime.h"

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
	[defaultDict setValue:[NSData data] forKey:@"license"];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultDict];
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultDict];
	
	NSMutableString *key = [NSMutableString string];
	[key appendString:@"0xC294FB5"];
	[key appendString:@"B"];
	[key appendString:@"B"];
	[key appendString:@"3C806FA10CC021FE0C1"];
	[key appendString:@"F36F4CA419B0FC1F"];
	[key appendString:@"2"];
	[key appendString:@"2"];
	[key appendString:@"5273BEB36DCC"];
	[key appendString:@""];
	[key appendString:@"4"];
	[key appendString:@"4"];
	[key appendString:@"5FC3750DE496F1EF935B58C763BE"];
	[key appendString:@"8FAB835D96CED323520CB9F6C1C480"];
	[key appendString:@""];
	[key appendString:@"B"];
	[key appendString:@"B"];
	[key appendString:@"146164010E87558510519807C8E4"];
	[key appendString:@"59548756FC4B17"];
	[key appendString:@"C"];
	[key appendString:@"C"];
	[key appendString:@"706E3C30C231D4"];
	[key appendString:@"2"];
	[key appendString:@"4"];
	[key appendString:@"4"];
	[key appendString:@"0CB3AF7CAC8F5DA21A2F63F1BE2"];
	[key appendString:@"0B89CD402C0307A6E6450657A1ACFC"];
	[key appendString:@"152258187942FDC737"];
	
	APSetKey((CFStringRef )key);
}

- (void) awakeFromNib
{
	
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	if( [[filename pathExtension] isEqualToString:@"questionablelicense"] ) {
		
		NSData *newLicenseData = [NSData dataWithContentsOfFile:filename];
		if( newLicenseData == nil )
			return NO;
		
		if( !APVerifyLicenseData( (CFDataRef ) newLicenseData ) ) {
			NSAlert *alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"OK"];
			[alert setMessageText:@"This is an invalid license file."];
			[alert setInformativeText:filename];
			[alert setAlertStyle:NSWarningAlertStyle];
			[alert runModal];
			
			[alert release];
			return NO;
		}
		
		NSDictionary *prefs = [[NSUserDefaultsController sharedUserDefaultsController] values];
		NSDictionary *licenseDict = (NSDictionary *)APCreateDictionaryForLicenseData((CFDataRef )[prefs valueForKey:@"license"]);
		if( APVerifyLicenseData( (CFDataRef )[prefs valueForKey:@"license"] ) ) {
			NSAlert *alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"OK"];
			[alert setMessageText:@"You already have a valid license for this application."];
			[alert setInformativeText:[NSString stringWithFormat:@"Licensed to: %@ (%@)", [licenseDict valueForKey:@"Name"], [licenseDict valueForKey:@"Email"]]];
			[alert setAlertStyle:NSInformationalAlertStyle];
			[alert runModal];

			[licenseDict release];
			[alert release];
			return NO;
		}
		
		[NSApp willChangeValueForKey:@"registeredString"];
		[prefs setValue:newLicenseData forKey:@"license"];
		[NSApp didChangeValueForKey:@"registeredString"];

		return YES;
	} else
		return [viewController openGameFile:filename];
}

@end

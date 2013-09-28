//
//  PrefsValidator.m
//  Questionable
//
//  Created by Nur Monson on 6/23/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "PrefsValidator.h"


@implementation PrefsValidator

- (BOOL)control:(NSControl *)control didFailToFormatString:(NSString *)string errorDescription:(NSString *)error
{
	NSString *alertTitle = nil;
	NSString *alertMessage = nil;
	NSString *suggestAlternate = nil;
	SEL alertSheetSelector = nil;
	id contextInfo = nil;
	
	if( control == _gameLengthField ) {
		int gameTime = [string intValue];
		if( gameTime < 10 ) {
			alertTitle = NSLocalizedString(@"Game Length Too Short",@"Game Length Too Short");
			alertMessage = NSLocalizedString(@"The length of a game can be from 10 to 300 minutes. The time you entered is less than 10.",
											 @"The length of a game can be from 10 to 300 minutes. The time you entered is less than 10.");
			suggestAlternate = NSLocalizedString(@"Set to 10 minutes",@"Set to 10 minutes");
			contextInfo = @"10";
			alertSheetSelector = @selector(gameLengthSheetDidEnd:returnCode:contextInfo:);
		} else if( gameTime > 300 ) {
			alertTitle = NSLocalizedString(@"Game Length Too Long",@"Game Length Too Long");
			alertMessage = NSLocalizedString(@"The length of a game can be from 10 to 300 minutes. The time you entered is more than 300.",
											 @"The length of a game can be from 10 to 300 minutes. The time you entered is more than 300.");
			suggestAlternate = NSLocalizedString(@"Set to 300 minutes",@"Set to 300 minutes");
			contextInfo = @"300";
			alertSheetSelector = @selector(gameLengthSheetDidEnd:returnCode:contextInfo:);
		}
	} else if( control == _questionLengthField ) {
		int questionTime = [string intValue];
		if( questionTime < 5 ) {
			alertTitle = NSLocalizedString(@"Question Length Too Short",@"Question Length Too Short");
			alertMessage = NSLocalizedString(@"The length of a question can be from 5 to 200 seconds. The time you entered is less than 5.",
											 @"The length of a question can be from 5 to 200 seconds. The time you entered is less than 5.");
			suggestAlternate = NSLocalizedString(@"Set to 5 minutes",@"Set to 5 seconds");
			contextInfo = @"5";
			alertSheetSelector = @selector(questionLengthSheetDidEnd:returnCode:contextInfo:);
		} else if( questionTime > 200 ) {
			alertTitle = NSLocalizedString(@"Question Length Too Long",@"Question Length Too Long");
			alertMessage = NSLocalizedString(@"The length of a question can be from 5 to 200 seconds. The time you entered is more than 200.",
											 @"The length of a question can be from 5 to 200 seconds. The time you entered is more than 200.");
			suggestAlternate = NSLocalizedString(@"Set to 200 minutes",@"Set to 200 seconds");
			contextInfo = @"200";
			alertSheetSelector = @selector(questionLengthSheetDidEnd:returnCode:contextInfo:);
		}
	}
	
	if( alertTitle == nil )
		return YES;
	
	NSBeginAlertSheet(alertTitle,suggestAlternate,nil,nil,[self window],self,alertSheetSelector,nil,contextInfo,@"%@",alertMessage);
	return YES;
}

- (void)gameLengthSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
	[_gameLengthField setStringValue:(NSString *)contextInfo];
}

- (void)questionLengthSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
	[_questionLengthField setStringValue:(NSString *)contextInfo];
}
@end

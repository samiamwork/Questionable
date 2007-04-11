//
//  NSApplicationExtensions.m
//  Questionable
//
//  Created by Nur Monson on 4/9/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "NSApplicationExtensions.h"
#import "AquaticPrime.h"

@interface NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
@end

@implementation NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL
{
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
    NSRange range = NSMakeRange(0, [attrString length]);
	
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
	
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
	
    // next make the text appear with an underline
    [attrString addAttribute:
            NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
	
    [attrString endEditing];
	
    return [attrString autorelease];
}
@end

@implementation NSApplication (TIPExtensions)

- (NSString *)registeredUserName
{
	NSData *licenseData = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"license"];
	NSDictionary *licenseDict = (NSDictionary *)APCreateDictionaryForLicenseData( (CFDataRef )licenseData );
	return [licenseDict valueForKey:@"name"];
}

- (NSString *)registeredString
{
	NSData *licenseData = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"license"];
	NSDictionary *licenseDict = (NSDictionary *)APCreateDictionaryForLicenseData( (CFDataRef )licenseData );
	
	if( licenseDict == nil )
		return @"Unregistered";
	
	return [licenseDict valueForKey:@"name"];
}

- (NSString *)registeredUserNumber
{
	NSData *licenseData = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"license"];
	NSDictionary *licenseDict = (NSDictionary *)APCreateDictionaryForLicenseData( (CFDataRef )licenseData );
	return [licenseDict valueForKey:@"ID"];
}

- (NSString *)registeredUserEmail
{
	NSData *licenseData = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"license"];
	NSDictionary *licenseDict = (NSDictionary *)APCreateDictionaryForLicenseData( (CFDataRef )licenseData );
	return [licenseDict valueForKey:@"email"];
}

- (BOOL)registered
{
	NSData *licenseData = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"license"];
	
	return APVerifyLicenseData( (CFDataRef )licenseData );
}

@end

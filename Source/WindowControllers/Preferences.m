//
//  Preferences.m
//  NibTest
//
//  Created by Nur Monson on 4/11/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "Preferences.h"


@implementation Preferences

- (IBAction)showPanel:(id)sender
{
	if(!prefWindow) {
		if(![NSBundle loadNibNamed:@"Preferences" owner:self])  {
			NSLog(@"Failed to load Preferences.nib");
			NSBeep();
			return;
		}
		[prefWindow setHidesOnDeactivate:NO];
		[prefWindow setExcludedFromWindowsMenu:YES];
		[prefWindow setMenu:nil];

		[prefWindow center];
    }
    [prefWindow makeKeyAndOrderFront:nil];
}

@end

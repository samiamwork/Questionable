//
//  TIPImage.h
//  TriviaOutlineView
//
//  Created by Nur Monson on 1/30/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TIPImage : NSImage {
	NSString *thePathToFile;
}

- (NSString *)pathToFile;
- (void)setPathToFile:(NSString *)newPathToFile;
@end

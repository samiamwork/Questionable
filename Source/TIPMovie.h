//
//  TIPMovie.h
//  TriviaOutlineView
//
//  Created by Nur Monson on 1/30/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@interface TIPMovie : QTMovie {
	NSString *thePathToFile;
}

- (NSString *)pathToFile;
- (void)setPathToFile:(NSString *)newPathToFile;
@end

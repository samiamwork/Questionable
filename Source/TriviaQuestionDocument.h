//
//  TriviaQuestionDocument.h
//  TriviaOutlineView
//
//  Created by Nur Monson on 1/31/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaClasses/TriviaBoard.h"
#import "TIPFileArchiver.h"

@interface TriviaQuestionDocument : NSDocument {
	NSMutableArray *theBoards;
}

- (NSArray *)boards;
- (void)setBoards:(NSArray *)newBoards;
- (void)addBoard:(TriviaBoard *)aBoard;
- (void)removeBoard:(TriviaBoard *)aBoard;

@end

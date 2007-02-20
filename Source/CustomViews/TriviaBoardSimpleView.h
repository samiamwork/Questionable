//
//  TriviaBoardSimpleView.h
//  TriviaPlayer
//
//  Created by Nur Monson on 10/19/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaBoard.h"
#import "TIPTextContainer.h"

@interface TriviaBoardSimpleView : NSView {
	TriviaBoard *mainBoard;
	unsigned numberOfCategories;
	unsigned questionsPerCategory;
	
	IBOutlet id delegate;
	
	TIPTextContainer *placeholderMessage;
	NSMutableArray *titleArray;
	NSMutableArray *pointArray;
	NSMutableArray *usedQuestionsArray;

	BOOL enabled;
}

- (void)setDelegate:(id)newDelegate;
- (id)delegate;
- (void)setBoard:(TriviaBoard *)newBoard;
- (TriviaBoard *)board;

- (void)setEnable:(BOOL)isEnable;
- (void)enable:(BOOL)enable question:(unsigned)theQuestionIndex inCategory:(unsigned)theCategoryIndex;
@end

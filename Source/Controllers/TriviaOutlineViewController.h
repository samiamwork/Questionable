//
//  TriviaOutlineViewController.h
//  TriviaOutlineView
//
//  Created by Nur Monson on 1/18/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaOutlineView.h"
#import "TriviaBoard.h"
#import "ButtonTextCell.h"
#import "QuestionView.h"
#import "TriviaQuestionDocument.h"
#import "TIPFileArchiver.h"


@interface TriviaOutlineViewController : NSObject {
	TriviaQuestionDocument *theQuestionDoc;
	
	TriviaBoard *checkedoutBoard;
	
	TriviaBoard *currentBoard;
	TriviaCategory *currentCategory;
	TriviaQuestion *currentQuestion;
	
	id theDraggedItem;
	
	IBOutlet NSWindowController *triviaWindowController;
	IBOutlet TriviaOutlineView *theOutlineView;
	IBOutlet NSTabView *theTabView;
	IBOutlet QuestionView *theQuestionView;
	IBOutlet NSObjectController *theQuestionController;
}

- (TriviaBoard *)checkoutBoard;
- (void)checkinBoard;

- (BOOL)openGameFile:(NSString *)filename;

- (IBAction)addBoard:(id)sender;
- (IBAction)addCategory:(id)sender;
- (IBAction)addItem:(id)sender;
- (IBAction)deleteItem:(id)sender;
- (IBAction)openGame:(id)sender;
- (IBAction)saveGame:(id)sender;

- (TriviaBoard *)currentBoard;
- (void)setCurrentBoard:(TriviaBoard *)newBoard;

- (TriviaCategory *)currentCategory;
- (void)setCurrentCategory:(TriviaCategory *)newCategory;

- (TriviaQuestion *)currentQuestion;
- (void)setCurrentQuestion:(TriviaQuestion *)newQuestion;

- (id)draggedItem;
- (void)setDraggedItem:(id)newDraggedItem;
@end

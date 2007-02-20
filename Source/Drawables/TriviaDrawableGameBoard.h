//
//  TriviaDrawableGameBoard.h
//  TriviaPlayer
//
//  Created by Nur Monson on 10/8/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaBoard.h"
#import "TriviaDrawable.h"
#import "TIPTextContainer.h"
#import "TriviaDrawablePointsBox.h"
#import "TriviaDrawableCategoryTitleBox.h"
//#import "CTGradient.h"
#import "TIPGradient.h"


@interface TriviaDrawableGameBoard : TriviaDrawable {
	// mutable Array of Category Text Containers.
	NSMutableArray *categoryTitles;
	NSMutableArray *categoryPoints;
	TriviaBoard *board;
	// Array of Points text containers
	NSArray *unusedPoints;
	NSArray *usedPoints;
	
	TIPTextContainer *titleContainer;
	TIPTextContainer *pointsContainer;
	TriviaDrawablePointsBox *pointsBox;
	TriviaDrawableCategoryTitleBox *titleBox;
	
	unsigned questionCount;
	
	// visual junk
	TIPGradientRef blackShine;
	NSColor *availableColor;
	NSColor *disabledColor;
}

//- (void)setCategoryTitles:(NSArray *)newCategoryTitles;
- (void)setBoard:(TriviaBoard *)newBoard;
- (TriviaBoard *)board;
//- (void)enable:(BOOL)enable question:(unsigned)theQuestionIndex inCategory:(unsigned)theCategoryIndex;
@end

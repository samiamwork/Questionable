//
//  TriviaBoard.h
//  TriviaPlayer
//
//  Created by Nur Monson on 9/28/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaCategory.h"
#import "TIPFileArchiver.h"


@interface TriviaBoard : NSObject <NSCoding> {
	NSString *theTitle;
	NSMutableArray *theCategories;
}

- (NSString *)title;
- (void)setTitle:(NSString *)newTitle;

- (NSMutableArray *)categories;
- (void)setCategories:(NSArray *)newCategories;
- (void)addCategory:(TriviaCategory *)newCategory;
- (void)removeCategory:(TriviaCategory *)aCategory;
- (void)insertObject:(TriviaCategory *)aCategory inCategoriesAtIndex:(unsigned int)anIndex;

- (BOOL)allUsed;
- (BOOL)isFull;
- (BOOL)categoryChange;
- (void)setUsed;
- (void)setUnused;

- (NSArray *)categoryTitles;
- (TriviaQuestion *)getQuestion:(unsigned)questionIndex inCategory:(unsigned)categoryIndex;

- (NSMutableDictionary *)encodeAsMutableDictionaryWithArchiver:(TIPFileArchiver *)anArchiver;
+ (TriviaBoard *)boardFromDictionary:(NSDictionary *)aBoardDictionary inPath:(NSString *)aPath;
@end

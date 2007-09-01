//
//  TriviaCategory.h
//  BindingsTrivia
//
//  Created by Nur Monson on 9/18/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaQuestion.h"
#import "TIPFileArchiver.h"

@interface TriviaCategory : NSObject <NSCoding> {
	NSString *theTitle;
	NSMutableArray *theQuestions;
	
	BOOL _isCopy;
	id parent;
}

- (BOOL)allUsed;
- (BOOL)isFull;
- (void)setUsed;
- (void)setUnused;

- (NSString *)title;
- (void)setTitle:(NSString *)newTitle;

- (NSMutableArray *)questions;
- (void)setQuestions:(NSArray *)newQuestions;
- (void)addQuestion:(TriviaQuestion *)newQuestion;
- (void)removeQuestion:(TriviaQuestion *)aQuestion;
- (void)insertObject:(TriviaQuestion *)aQuestion inQuestionsAtIndex:(unsigned int)anIndex;

- (id)parent;
- (void)setParent:(id)newParent;

- (NSMutableDictionary *)encodeAsMutableDictionaryWithArchiver:(TIPFileArchiver *)anArchiver;
+ (TriviaCategory *)categoryFromDictionary:(NSDictionary *)aCategoryDictionary inPath:(NSString *)aPath;
@end

//
//  TriviaBoard.m
//  TriviaPlayer
//
//  Created by Nur Monson on 9/28/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaBoard.h"

#define MAXCATEGORIES 5

@implementation TriviaBoard

+ (void)initialize
{
	NSArray *keys = [NSArray arrayWithObjects:@"title",nil];
	[TriviaBoard setKeys:keys triggerChangeNotificationsForDependentKey:@"anyPropertyChanged"];
}

- (BOOL)anyPropertyChanged
{
	return YES;
}

- (id)init
{
	if( (self = [super init]) ) {
		
		theTitle = [[NSString alloc] initWithString:@"Round 1"];
		theCategories = [[NSMutableArray alloc] init];
	
	}
	
	return self;
}

- (void)dealloc
{
	[theTitle release];
	[theCategories release];
	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	TriviaBoard *copyTriviaBoard = [[TriviaBoard alloc] init];
	copyTriviaBoard->theCategories = [theCategories copyWithZone:zone];
	[copyTriviaBoard setTitle:theTitle];
	
	return copyTriviaBoard;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
	if( (self = [super init]) ) {
		[self setTitle:[decoder decodeObjectForKey:@"title"]];
		[self setCategories:[decoder decodeObjectForKey:@"categories"]];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:theTitle forKey:@"title"];
	[encoder encodeObject:theCategories forKey:@"categories"];
}

- (NSMutableDictionary *)encodeAsMutableDictionaryWithArchiver:(TIPFileArchiver *)anArchiver
{
	NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
	NSMutableArray *categoryDictionaries = [NSMutableArray array];
	
	[newDictionary setValue:theTitle forKey:@"title"];
	
	NSEnumerator *categoryEnumerator = [theCategories objectEnumerator];
	TriviaCategory *aCategory;
	while( (aCategory = [categoryEnumerator nextObject]) )
		[categoryDictionaries addObject:[aCategory encodeAsMutableDictionaryWithArchiver:anArchiver]];

	[newDictionary setValue:categoryDictionaries forKey:@"categories"];
	
	return newDictionary;
}

+ (TriviaBoard *)boardFromDictionary:(NSDictionary *)aBoardDictionary inPath:(NSString *)aPath
{
	TriviaBoard *newBoard = [[TriviaBoard alloc] init];
	
	[newBoard setTitle:[aBoardDictionary valueForKey:@"title"]];
	
	NSMutableArray *aCategoryArray = [NSMutableArray array];
	
	NSEnumerator *categoryEnumerator = [[aBoardDictionary valueForKey:@"categories"] objectEnumerator];
	NSDictionary *aCategoryDictionary;
	while( (aCategoryDictionary = [categoryEnumerator nextObject]) )
		[aCategoryArray addObject:[TriviaCategory categoryFromDictionary:aCategoryDictionary inPath:aPath]];
	
	[newBoard setCategories:aCategoryArray];
	
	return [newBoard autorelease];
}

#pragma mark Accessor Methods

- (NSString *)title
{
	return theTitle;
}
- (void)setTitle:(NSString *)newTitle
{
	if( newTitle == theTitle )
		return;
	
	[theTitle release];
	theTitle = [newTitle retain];
}
- (BOOL)validateTitle:(id *)ioValue error:(NSError **)outError
{
	if( [(NSString *)*ioValue length] > 0 )
		return YES;
	
	NSString *errorString = NSLocalizedString(@"Rounds must not have blank titles.", @"Rounds must not have blank titles.");
	NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey];
	*outError = [[[NSError alloc] initWithDomain:@"TriviaBoard Domain" code:1 userInfo:errorInfo] autorelease];
	
	return NO;
}

- (NSMutableArray *)categories
{
	return theCategories;
}
- (void)setCategories:(NSArray *)newCategories
{
	if( newCategories == theCategories || [newCategories count] > MAXCATEGORIES )
		return;
	
	[theCategories release];
	theCategories = [[NSMutableArray alloc] initWithArray:newCategories];
	[theCategories makeObjectsPerformSelector:@selector(setParent:) withObject:self];
}

- (void)addCategory:(TriviaCategory *)newCategory
{
	if( newCategory == nil || [self isFull] )
		return;
	
	[newCategory setParent:self];
	[theCategories addObject:newCategory];
}
- (void)removeCategory:(TriviaCategory *)aCategory
{
	if( aCategory == nil )
		return;
	
	unsigned categoryIndex = [theCategories indexOfObject:aCategory];
	if( categoryIndex == NSNotFound )
		return;
	
	[theCategories removeObjectAtIndex:categoryIndex];
	if( [theCategories count] != 0 )
		return;
	
	TriviaCategory *replacementCategory = [[TriviaCategory alloc] init];
	[self addCategory:replacementCategory];
	[replacementCategory release];
}
- (void)insertObject:(TriviaCategory *)aCategory inCategoriesAtIndex:(unsigned int)anIndex
{
	unsigned foundIndex = [theCategories indexOfObject:aCategory];
	if( [self isFull] && foundIndex == NSNotFound )
		return;
	
	if( foundIndex != NSNotFound )
		[theCategories exchangeObjectAtIndex:anIndex withObjectAtIndex:foundIndex];
	else
		[theCategories insertObject:aCategory atIndex:anIndex];
}

- (BOOL)allUsed
{
	TriviaCategory *aCategory;
	NSEnumerator *categoryEnumerator = [theCategories objectEnumerator];
	
	while( (aCategory = [categoryEnumerator nextObject]) ) {
		if( ![aCategory allUsed] )
			return NO;
	}
	
	return YES;
}
- (BOOL)isFull
{
	if( [theCategories count] < MAXCATEGORIES )
		return NO;
	
	return YES;
}

- (NSArray *)categoryTitles
{
	NSMutableArray *titleArray = [NSMutableArray array];
	NSEnumerator *categoryEnumerator = [theCategories objectEnumerator];
	TriviaCategory *aCategory;
	
	while( (aCategory = [categoryEnumerator nextObject]) )
		[titleArray addObject:[aCategory title]];
	
	return titleArray;
}

- (TriviaQuestion *)getQuestion:(unsigned)questionIndex inCategory:(unsigned)categoryIndex
{
	return [[[theCategories objectAtIndex:categoryIndex] questions] objectAtIndex:questionIndex];
}

- (NSString *)description
{
	return theTitle;
}
@end

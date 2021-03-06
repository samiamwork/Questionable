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

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
	if([key isEqualToString:@"anyPropertyChanged"])
		return [NSSet setWithObjects:@"title", @"categoryChange", nil];
	return [super keyPathsForValuesAffectingValueForKey:key];
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
	
	NSEnumerator *categoryEnumerator = [theCategories objectEnumerator];
	TriviaCategory *aCategory;
	while( (aCategory = [categoryEnumerator nextObject]) )
		[aCategory removeObserver:self forKeyPath:@"anyPropertyChanged"];
	
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
	
	//NSMutableArray *aCategoryArray = [NSMutableArray array];
	
	NSEnumerator *categoryEnumerator = [[aBoardDictionary valueForKey:@"categories"] objectEnumerator];
	NSDictionary *aCategoryDictionary;
	while( (aCategoryDictionary = [categoryEnumerator nextObject]) ) {
		//[aCategoryArray addObject:[TriviaCategory categoryFromDictionary:aCategoryDictionary inPath:aPath]];
		[newBoard addCategory:[TriviaCategory categoryFromDictionary:aCategoryDictionary inPath:aPath]];
	}
	
	//[newBoard setCategories:aCategoryArray];
	
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
	
	NSEnumerator *categoryEnumerator = [theCategories objectEnumerator];
	TriviaCategory *aCategory;
	while( (aCategory = [categoryEnumerator nextObject]) )
		[aCategory removeObserver:self forKeyPath:@"anyPropertyChanged"];
	
	[theCategories release];
	theCategories = [[NSMutableArray alloc] initWithArray:newCategories];
	[theCategories makeObjectsPerformSelector:@selector(setParent:) withObject:self];
	
	categoryEnumerator = [theCategories objectEnumerator];
	while( (aCategory = [categoryEnumerator nextObject]) )
		[aCategory addObserver:self forKeyPath:@"anyPropertyChanged" options:NSKeyValueObservingOptionNew context:nil];
	
	[self willChangeValueForKey:@"categoryChange"];
	[self didChangeValueForKey:@"categoryChange"];
}

- (void)addCategory:(TriviaCategory *)newCategory
{
	if( newCategory == nil || [self isFull] )
		return;
	
	[newCategory addObserver:self forKeyPath:@"anyPropertyChanged" options:NSKeyValueObservingOptionNew context:nil];
	[newCategory setParent:self];
	[theCategories addObject:newCategory];
	
	[self willChangeValueForKey:@"categoryChange"];
	[self didChangeValueForKey:@"categoryChange"];
}
- (void)removeCategory:(TriviaCategory *)aCategory
{
	if( aCategory == nil )
		return;
	
	NSUInteger categoryIndex = [theCategories indexOfObject:aCategory];
	if( categoryIndex == NSNotFound )
		return;
	
	[[theCategories objectAtIndex:categoryIndex] removeObserver:self forKeyPath:@"anyPropertyChanged"];
	[theCategories removeObjectAtIndex:categoryIndex];
	if( [theCategories count] != 0 )
		return;
	
	TriviaCategory *replacementCategory = [[TriviaCategory alloc] init];
	[replacementCategory addObserver:self forKeyPath:@"anyPropertyChanged" options:NSKeyValueObservingOptionNew context:nil];
	[self addCategory:replacementCategory];
	[replacementCategory release];
	
	[self willChangeValueForKey:@"categoryChange"];
	[self didChangeValueForKey:@"categoryChange"];
}
- (void)insertObject:(TriviaCategory *)aCategory inCategoriesAtIndex:(unsigned int)anIndex
{
	NSUInteger foundIndex = [theCategories indexOfObject:aCategory];
	if( [self isFull] && foundIndex == NSNotFound )
		return;
	
	if( foundIndex == NSNotFound ) {
		[aCategory addObserver:self forKeyPath:@"anyPropertyChanged" options:NSKeyValueObservingOptionNew context:nil];
		[theCategories insertObject:aCategory atIndex:anIndex];
	} else
		[theCategories exchangeObjectAtIndex:anIndex withObjectAtIndex:foundIndex];
	
	[self willChangeValueForKey:@"categoryChange"];
	[self didChangeValueForKey:@"categoryChange"];
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

- (void)setUsed
{
	[theCategories makeObjectsPerformSelector:@selector(setUsed)];
}

- (void)setUnused
{
	[theCategories makeObjectsPerformSelector:@selector(setUnused)];
}

- (BOOL)categoryChange
{
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if( ![keyPath isEqualToString:@"anyPropertyChanged"] )
		return;
	
	[self willChangeValueForKey:@"categoryChange"];
	[self didChangeValueForKey:@"categoryChange"];
}
@end

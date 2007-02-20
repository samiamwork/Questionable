//
//  TriviaCategory.m
//  BindingsTrivia
//
//  Created by Nur Monson on 9/18/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaCategory.h"
//#import "TriviaQuestion.h"

#define MAXQUESTIONS 5

@implementation TriviaCategory

+ (void)initialize
{
	NSArray *keys = [NSArray arrayWithObjects:@"title",nil];
	[TriviaCategory setKeys:keys triggerChangeNotificationsForDependentKey:@"anyPropertyChanged"];
}

- (BOOL)anyPropertyChanged
{
	return YES;
}

- (id)init
{
	if( (self = [super init]) ) {

		theTitle = @"New Category";
		theQuestions = [[NSMutableArray alloc] init];
		
		int questionNumber;
		for( questionNumber = 0; questionNumber < MAXQUESTIONS; questionNumber++ ) {
			TriviaQuestion *newQuestion = [[TriviaQuestion alloc] init];
			[self addQuestion:newQuestion];
			[newQuestion release];
		}
		
		parent = nil;
	}
	
	return self;
}

- (void)dealloc
{
	[theQuestions release];
	[theTitle release];
	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	TriviaCategory *copyTriviaCategory = [[TriviaCategory alloc] init];
	copyTriviaCategory->theQuestions = [theQuestions copyWithZone:zone];
	[copyTriviaCategory setTitle:[self title]];
	[copyTriviaCategory setParent:[self parent]];
	
	return copyTriviaCategory;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
	if( (self = [super init]) ) {
		[self setTitle:[decoder decodeObjectForKey:@"title"]];
		[self setQuestions:[decoder decodeObjectForKey:@"questions"]];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:theTitle forKey:@"title"];
	[encoder encodeObject:theQuestions forKey:@"questions"];
}

- (NSMutableDictionary *)encodeAsMutableDictionaryWithArchiver:(TIPFileArchiver *)anArchiver
{
	NSMutableDictionary *categoryDictionary = [NSMutableDictionary dictionary];
	NSMutableArray *questionArray = [NSMutableArray array];
	
	[categoryDictionary setValue:theTitle forKey:@"title"];
	
	NSEnumerator *questionEnumerator = [theQuestions objectEnumerator];
	TriviaQuestion *aQuestion;
	while( (aQuestion = [questionEnumerator nextObject]) )
		[questionArray addObject:[aQuestion encodeAsMutableDictionaryWithArchiver:anArchiver]];
	
	[categoryDictionary setValue:questionArray forKey:@"questions"];
	
	return categoryDictionary;
}

+ (TriviaCategory *)categoryFromDictionary:(NSDictionary *)aCategoryDictionary inPath:(NSString *)aPath
{
	TriviaCategory *newCategory = [[TriviaCategory alloc] init];
	
	[newCategory setTitle:[aCategoryDictionary valueForKey:@"title"]];
	
	NSMutableArray *aQuestionArray = [NSMutableArray array];
	
	NSEnumerator *aQuestionEnumerator = [[aCategoryDictionary valueForKey:@"questions"] objectEnumerator];
	NSDictionary *aQuestionDictionary;
	while( (aQuestionDictionary = [aQuestionEnumerator nextObject]) )
		[aQuestionArray addObject:[TriviaQuestion questionFromDictionary:aQuestionDictionary inPath:aPath]];
	
	[newCategory setQuestions:aQuestionArray];
	
	return [newCategory autorelease];
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
	
	NSString *errorString = NSLocalizedString(@"Categories must not have blank titles.", @"Categories must not have blank titles.");
	NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey];
	*outError = [[[NSError alloc] initWithDomain:@"TriviaCategory Domain" code:2 userInfo:errorInfo] autorelease];
	
	return NO;
}

- (NSMutableArray *)questions
{
	return theQuestions;
}
- (void)setQuestions:(NSArray *)newQuestions
{
	if( newQuestions == theQuestions || [newQuestions count] > MAXQUESTIONS )
		return;
	
	[theQuestions release];
	theQuestions = [[NSMutableArray alloc] initWithArray:newQuestions];
	[theQuestions makeObjectsPerformSelector:@selector(setParent:) withObject:self];
}

- (void)addQuestion:(TriviaQuestion *)newQuestion
{
	if( newQuestion == nil || [self isFull] )
		return;
	[newQuestion setParent:self];
	[theQuestions addObject:newQuestion];
}
- (void)removeQuestion:(TriviaQuestion *)aQuestion
{
	if( aQuestion == nil )
		return;
	//[aQuestion setParent:nil];
	[theQuestions removeObject:aQuestion];
}
- (void)insertObject:(TriviaQuestion *)aQuestion inQuestionsAtIndex:(unsigned int)anIndex
{
	unsigned foundIndex = [theQuestions indexOfObject:aQuestion];
	if( [self isFull] && foundIndex == NSNotFound )
		return;
	
	if( foundIndex != NSNotFound )
		[theQuestions exchangeObjectAtIndex:anIndex withObjectAtIndex:foundIndex];
	else
		[theQuestions insertObject:aQuestion atIndex:anIndex];
}

- (id)parent
{
	return parent;
}
- (void)setParent:(id)newParent
{
	parent = newParent;
}

- (BOOL)allUsed
{
	TriviaQuestion *aQuestion;
	NSEnumerator *questionEnumerator = [theQuestions objectEnumerator];
	
	while( (aQuestion = [questionEnumerator nextObject]) ) {
		if( ![aQuestion used] )
			return NO;
	}
	
	return YES;
}

- (BOOL)isFull
{
	if( [theQuestions count] < MAXQUESTIONS )
		return NO;
	
	return YES;
}

- (NSString *)description
{
	return theTitle;
}

@end

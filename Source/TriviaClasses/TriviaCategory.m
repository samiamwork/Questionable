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
	NSArray *keys = [NSArray arrayWithObjects:@"title",@"questions",@"questionChange",nil];
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
	NSEnumerator *questionEnumerator = [theQuestions objectEnumerator];
	TriviaQuestion *aQuestion;
	while( (aQuestion = [questionEnumerator nextObject]) )
		[aQuestion removeObserver:self forKeyPath:@"anyPropertyChanged"];
	
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
	[self willChangeValueForKey:@"questionChange"];
	NSEnumerator *questionEnumerator = [theQuestions objectEnumerator];
	TriviaQuestion *aQuestion;
	while( (aQuestion = [questionEnumerator nextObject]) )
		[aQuestion removeObserver:self forKeyPath:@"anyPropertyChanged"];
	
	[theQuestions release];
	theQuestions = [[NSMutableArray alloc] initWithArray:newQuestions];
	
	questionEnumerator = [theQuestions objectEnumerator];
	while( (aQuestion = [questionEnumerator nextObject]) ) {
		[aQuestion addObserver:self forKeyPath:@"anyPropertyChanged" options:NSKeyValueObservingOptionNew context:nil];
		[aQuestion setParent:self];
	}
	[self didChangeValueForKey:@"questionChange"];
}

- (void)addQuestion:(TriviaQuestion *)newQuestion
{
	if( newQuestion == nil || [self isFull] )
		return;
	[newQuestion setParent:self];
	[newQuestion addObserver:self forKeyPath:@"anyPropertyChanged" options:NSKeyValueObservingOptionNew context:nil];
	[theQuestions addObject:newQuestion];
}
- (void)removeQuestion:(TriviaQuestion *)aQuestion
{
	if( aQuestion == nil )
		return;
	
	unsigned questionIndex = [theQuestions indexOfObject:aQuestion];
	if( questionIndex == NSNotFound )
		return;
	
	[aQuestion removeObserver:self forKeyPath:@"anyPropertyChanged"];
	TriviaQuestion *replacementQuestion = [[TriviaQuestion alloc] init];
	[replacementQuestion addObserver:self forKeyPath:@"anyPropertyChanged" options:NSKeyValueObservingOptionNew context:nil];
	[theQuestions replaceObjectAtIndex:questionIndex withObject:replacementQuestion];
	[replacementQuestion release];
}
- (void)insertObject:(TriviaQuestion *)aQuestion inQuestionsAtIndex:(unsigned int)anIndex
{
	unsigned foundIndex = [theQuestions indexOfObject:aQuestion];
	if( ([self isFull] && foundIndex == NSNotFound) || anIndex == foundIndex )
		return;
	
	[theQuestions insertObject:aQuestion atIndex:anIndex];
	if( foundIndex == NSNotFound ) {
		[aQuestion addObserver:self forKeyPath:@"anyPropertyChanged" options:NSKeyValueObservingOptionNew context:nil];
	} else {
		if( anIndex <= foundIndex )
			[theQuestions removeObjectAtIndex:foundIndex+1];
		else
			[theQuestions removeObjectAtIndex:foundIndex];
	}
		
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

- (void)setUsed
{
	NSEnumerator *questionEnumerator = [theQuestions objectEnumerator];
	TriviaQuestion *aQuestion;
	while( (aQuestion = [questionEnumerator nextObject]) )
		[aQuestion setUsed:YES];
}

- (void)setUnused
{
	NSEnumerator *questionEnumerator = [theQuestions objectEnumerator];
	TriviaQuestion *aQuestion;
	while( (aQuestion = [questionEnumerator nextObject]) )
		[aQuestion setUsed:NO];
}

- (NSString *)description
{
	return theTitle;
}

#pragma mark KVO
- (BOOL)questionChange
{
	return YES;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if( [keyPath isEqualToString:@"anyPropertyChanged"] ) {
		[self willChangeValueForKey:@"questionChange"];
		[self didChangeValueForKey:@"questionChange"];
	}
}

@end

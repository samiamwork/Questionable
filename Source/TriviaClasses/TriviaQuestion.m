//
//  TriviaQuestion.m
//  BindingsTrivia
//
//  Created by Nur Monson on 9/18/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaQuestion.h"

typedef enum TriviaQuestionType {
	TriviaQuestionTypeString = 0,
	TriviaQuestionTypeImage,
	TriviaQuestionTypeMovie
} TriviaQuestionType;

@implementation TriviaQuestion

+ (void)initialize
{
	NSArray *keys = [NSArray arrayWithObjects:@"question",@"answer",nil];
	[TriviaQuestion setKeys:keys triggerChangeNotificationsForDependentKey:@"anyPropertyChanged"];
}

- (BOOL)anyPropertyChanged
{
	return YES;
}

- (id)init
{
	if( (self = [super init]) ) {
		theQuestion = nil;
		theAnswer = nil;
		_used = NO;
		_slowReveal = NO;
		
		theParent = nil;
		_isCopy = NO;
	}
	
	return self;
}

- (void)dealloc
{
	[theQuestion release];
	[theAnswer release];
	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	//HACK: we can only get away with this because it's only NSCell that calls this and will never modify it
	/*
	TriviaQuestion *copyTriviaQuestion = [[TriviaQuestion allocWithZone:zone] init];
	[copyTriviaQuestion setQuestion:theQuestion];
	copyTriviaQuestion->_isCopy = YES;
	[copyTriviaQuestion setAnswer:theAnswer];
	[copyTriviaQuestion setUsed:_used];
	[copyTriviaQuestion setSlowReveal:_slowReveal];
	// watch out! this was nil
	[copyTriviaQuestion setQuestionParent:nil];
	
	return copyTriviaQuestion;
	 */
	return [self retain];
}

- (NSString *)description
{
	if( theQuestion == nil || ([theQuestion isKindOfClass:[NSString class]] && [(NSString *)theQuestion length] == 0) )
		return @"<empty>";
	
	if( [theQuestion isKindOfClass:[NSString class]] )
		return (NSString *)theQuestion;
	else if( [theQuestion isKindOfClass:[QTMovie class]] || [theQuestion isKindOfClass:[NSImage class]] )
		return @"<Multimedia>";
	
	return @"<INVALID>";
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
	if( (self = [super init]) ) {
		[self setQuestion:[decoder decodeObjectForKey:@"question"]];
		[self setAnswer:[decoder decodeObjectForKey:@"answer"]];
		[self setUsed:[decoder decodeBoolForKey:@"used"]];
		[self setSlowReveal:[decoder decodeBoolForKey:@"slowReveal"]];
		
		[self setQuestionParent:nil];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:theQuestion forKey:@"question"];
	[encoder encodeObject:theAnswer forKey:@"answer"];
	[encoder encodeBool:_used forKey:@"used"];
	[encoder encodeBool:_slowReveal forKey:@"slowReveal"];
}

- (NSMutableDictionary *)encodeAsMutableDictionaryWithArchiver:(TIPFileArchiver *)anArchiver
{
	NSMutableDictionary *questionDictionary = [NSMutableDictionary dictionary];
	
	if( [theQuestion isKindOfClass:[NSImage class]] ) {
		
		[questionDictionary setValue:[NSNumber numberWithInt:TriviaQuestionTypeImage] forKey:@"questionType"];
		NSString *pathToImage = [anArchiver archiveFile:[(TIPImage *)theQuestion pathToFile] withDelegate:self context:NULL];
		[questionDictionary setValue:[pathToImage lastPathComponent] forKey:@"question"];
		[(TIPImage *)theQuestion setPathToFile:pathToImage];
		
	} else if( [theQuestion isKindOfClass:[QTMovie class]] ) {
		
		[questionDictionary setValue:[NSNumber numberWithInt:TriviaQuestionTypeMovie] forKey:@"questionType"];
		NSString *pathToMovie = [anArchiver archiveFile:[(TIPMovie *)theQuestion pathToFile] withDelegate:self context:NULL];
		[questionDictionary setValue:[pathToMovie lastPathComponent] forKey:@"question"];
		[(TIPMovie *)theQuestion setPathToFile:pathToMovie];
		
	} else {
		[questionDictionary setValue:[NSNumber numberWithInt:TriviaQuestionTypeString] forKey:@"questionType"];
		[questionDictionary setValue:theQuestion forKey:@"question"];
	}
	
	[questionDictionary setValue:theAnswer forKey:@"answer"];
	[questionDictionary setValue:[NSNumber numberWithBool:_used] forKey:@"used"];
	[questionDictionary setValue:[NSNumber numberWithBool:_slowReveal] forKey:@"slowReveal"];
	
	return questionDictionary;
}

+ (TriviaQuestion *)questionFromDictionary:(NSDictionary *)aQuestionDictionary inPath:(NSString *)aPath
{
	TriviaQuestion *newQuestion = [[TriviaQuestion alloc] init];
	
	[newQuestion setAnswer:[aQuestionDictionary valueForKey:@"answer"]];
	[newQuestion setUsed:[[aQuestionDictionary valueForKey:@"used"] boolValue]];
	[newQuestion setSlowReveal:[[aQuestionDictionary valueForKey:@"slowReveal"] boolValue]];
	
	TriviaQuestionType questionType = [[aQuestionDictionary valueForKey:@"questionType"] intValue];
	switch( questionType ) {
		case TriviaQuestionTypeString:
			[newQuestion setQuestion:[aQuestionDictionary valueForKey:@"question"]];
			break;
		case TriviaQuestionTypeImage: {
			NSString *imagePath = [aPath stringByAppendingPathComponent:[aQuestionDictionary valueForKey:@"question"]];
			TIPImage *anImage = [[TIPImage alloc] initWithContentsOfFile:imagePath];
			[anImage setPathToFile:imagePath];
			[newQuestion setQuestion:anImage];

			[anImage release];
			break; }
		case TriviaQuestionTypeMovie: {
			NSString *moviePath = [aPath stringByAppendingPathComponent:[aQuestionDictionary valueForKey:@"question"]];
			TIPMovie *aMovie = [[TIPMovie alloc] initWithFile:moviePath error:nil];
			[aMovie setPathToFile:moviePath];
			[newQuestion setQuestion:aMovie];
			
			[aMovie release];
			break; }
	}
	
	return [newQuestion autorelease];
}

#pragma mark Archiver Delegate Methods

- (void)errorWhileCopyingFrom:(NSString *)aPath withContext:(void *)aContext
{
	[(TIPImage *)theQuestion setPathToFile:aPath];
}

#pragma mark Accessor Methods

- (id)question
{
	return theQuestion;
}
- (void)setQuestion:(id)newQuestion
{
	if( newQuestion == theQuestion )
		return;
	
	[theQuestion release];
	theQuestion = [newQuestion retain];
}

- (NSString *)answer
{
	return theAnswer;
}
- (void)setAnswer:(NSString *)newAnswer
{
	if( newAnswer == theAnswer )
		return;
	
	[theAnswer release];
	theAnswer = [newAnswer retain];
}

- (BOOL)used
{
	return _used;
}
- (void)setUsed:(BOOL)isUsed
{
	_used = isUsed;
}

- (BOOL)slowReveal
{
	return _slowReveal;
}
- (void)setSlowReveal:(BOOL)willSlowReveal
{
	_slowReveal = willSlowReveal;
}

- (id)questionParent
{
	return theParent;
}
- (void)setQuestionParent:(id)newParent
{
	theParent = newParent;
}

@end

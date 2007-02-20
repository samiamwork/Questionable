//
//  TriviaQuestion.h
//  BindingsTrivia
//
//  Created by Nur Monson on 9/18/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "TIPFileArchiver.h"

#import "TIPMovie.h"
#import "TIPImage.h"

@interface TriviaQuestion : NSObject <NSCoding> {
	id theQuestion;
	NSString *theAnswer;
	BOOL _used;
	BOOL _slowReveal;
	
	id theParent;
}

- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;
- (NSMutableDictionary *)encodeAsMutableDictionaryWithArchiver:(TIPFileArchiver *)anArchiver;
+ (TriviaQuestion *)questionFromDictionary:(NSDictionary *)aQuestionDictionary inPath:(NSString *)aPath;

- (id)question;
- (void)setQuestion:(id)newQuestion;

- (NSString *)answer;
- (void)setAnswer:(NSString *)newAnswer;

- (BOOL)used;
- (void)setUsed:(BOOL)isUsed;

- (BOOL)slowReveal;
- (void)setSlowReveal:(BOOL)willSlowReveal;

- (id)parent;
- (void)setParent:(id)newParent;

@end

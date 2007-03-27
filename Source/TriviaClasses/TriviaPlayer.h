//
//  TriviaPlayer.h
//  TriviaPlayer
//
//  Created by Nur Monson on 9/25/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TIPInputManager.h"

@interface TriviaPlayer : NSObject {
	
	NSString *theName;
	int thePoints;
	TIPInputElement *inputElement;

	BOOL enabled;
}

- (NSString *)name;
- (void)setName:(NSString *)newName;
- (int)points;
- (void)setPoints:(int)newPoints;
- (void)addPoints:(int)addPoints;
- (void)subtractPoints:(int)subtractPoints;

- (BOOL)enabled;
- (void)setEnabled:(BOOL)isEnabled;

- (NSComparisonResult)sortByPoints:(id)anotherPlayer;

- (BOOL)isConnected;
//- (BOOL)setIsConnected:(BOOL)connected;

//- (void)registerInput;
- (TIPInputElement *)inputElement;
- (void)setInputElement:(TIPInputElement *)newElement;
- (BOOL)isButtonPressed;
@end

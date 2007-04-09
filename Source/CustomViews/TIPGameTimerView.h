//
//  TIPGameTimerView.h
//  TriviaPlayer
//
//  Created by Nur Monson on 11/20/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TIPTextContainer.h"
#import "TIPCGUtils.h"
#import "TIPGradient.h"

typedef enum _TriviaTimeDisplay {
	TriviaTimeDisplayMiliseconds = 1<<0,
	TriviaTimeDisplaySeconds = 1<<1,
	TriviaTimeDisplayMinutes = 1<<2,
	TriviaTimeDisplayHours = 1<<3,
} TriviaTimeDisplay;


@interface TIPGameTimerView : NSView {
	NSTimeInterval currentTime;
	NSTimeInterval maxTime;
	TIPTextContainer *timeContainer;
	TIPTextContainer *stoppedContainer;
	BOOL stopped;
	BOOL _countdown;
	TriviaTimeDisplay display;
}

- (NSTimeInterval)currentTime;
- (void)setCurrentTime:(NSTimeInterval)newTime;

- (NSTimeInterval)maxTime;
- (void)setMaxTime:(NSTimeInterval)newMaxTime;

- (BOOL)stopped;
- (void)setStopped:(BOOL)isStopped;

- (TriviaTimeDisplay)display;
- (void)setDisplay:(TriviaTimeDisplay)newDisplay;
@end

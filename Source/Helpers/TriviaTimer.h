//
//  TriviaTimer.h
//  TriviaPlayer
//
//  Created by Nur Monson on 11/2/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TriviaTimer : NSObject {
	id targetObject;
	SEL targetSelector;
	NSTimeInterval lastTime;
	NSTimeInterval timeElapsed;
	NSTimeInterval timeLength;
	NSTimeInterval timeInterval;
	
	NSTimer *timer;
	
	BOOL stopped;
	BOOL paused;
}

+ (TriviaTimer *)timerWithLength:(NSTimeInterval)length interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector;

- (NSTimeInterval)timeLength;
- (void)setTimeLength:(NSTimeInterval)length;
- (NSTimeInterval)timeElapsed;
- (void)setTimeInterval:(NSTimeInterval)interval;
- (void)setTarget:(id)target selector:(SEL)selector;

- (void)start;
- (void)stop;
- (void)pause;

- (BOOL)paused;
- (BOOL)stopped;
@end

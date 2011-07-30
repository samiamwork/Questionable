//
//  SimpleTimerView.h
//  Questionable
//
//  Created by Nur Monson on 6/26/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TransitionAnimation.h"

@interface SimpleTimerView : NSView<NSAnimationDelegate> {
	float _value;
	TransitionAnimation *_timerAnimation;
}

- (void)setValue:(float)newValue;
- (float)value;

- (void)startTimerOfLength:(NSTimeInterval)theLength;
- (void)pauseTimer;
- (void)resumeTimer;
- (void)stopTimer;
- (void)resetTimer;
@end

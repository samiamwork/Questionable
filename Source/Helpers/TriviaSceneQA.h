//
//  TriviaSceneQA.h
//  Questionable
//
//  Created by Nur Monson on 7/13/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RectangularBox.h"
#import "StringTexture.h"
#import "ArcTimer.h"

@interface TriviaSceneQA : NSObject <TextureScaling> {
	NSSize _size;
	float _scale;
	
	RectangularBox *_QATitleBox;
	RectangularBox *_QATextBox;
	RectangularBox *_shine;
	StringTexture *_titleString;
	StringTexture *_textString;
	
	ArcTimer *_qTimer;
}

- (void)setTitle:(NSString *)aTitle text:(NSString *)aText;
- (void)setProgress:(float)newProgress;
@end

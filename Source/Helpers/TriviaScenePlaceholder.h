//
//  TriviaScenePlaceholder.h
//  Questionable
//
//  Created by Nur Monson on 7/13/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RectangularBox.h"
#import "StringTexture.h"

@interface TriviaScenePlaceholder : NSObject <TextureScaling> {
	NSSize _size;
	float _scale;

	RectangularBox *_placeholderBox;
	RectangularBox *_placeholderShine;
	StringTexture *_questionmark;
}

- (void)updateColors;
@end

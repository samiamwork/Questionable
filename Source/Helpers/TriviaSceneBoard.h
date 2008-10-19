//
//  TriviaSceneBoard.h
//  Questionable
//
//  Created by Nur Monson on 7/12/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RectangularBox.h"
#import "StringTexture.h"

@interface TriviaSceneBoard : NSObject <TextureScaling> {
	NSSize _size;
	float _scale;
	
	RectangularBox *_categoryTitleBox;
	RectangularBox *_pointsBox;
	RectangularBox *_shine;
	
	NSSize _questionTitleSize;
	NSSize _questionPointSize;
	NSSize _pointStringSize;
	NSSize _titleStringSize;
	NSArray *_categories;
	NSMutableArray *_categoryTitleStrings;
	NSMutableArray *_questionPointStrings;
}

- (void)setCategories:(NSArray *)newCategories;
- (void)updateColors;
@end

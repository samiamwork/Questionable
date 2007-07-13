//
//  TriviaSceneBoard.m
//  Questionable
//
//  Created by Nur Monson on 7/12/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TriviaSceneBoard.h"
#import "TriviaBoard.h"


@implementation TriviaSceneBoard

- (id)init
{
	if( (self = [super init]) ) {
		_scale = 1.0f;
		
		_categoryTitleBox = [[RectangularBox alloc] init];
		[_categoryTitleBox setSharpCorners:BoxCornerLowerLeft|BoxCornerLowerRight];
		[_categoryTitleBox setStartColor:[NSColor colorWithCalibratedWhite:0.7f alpha:1.0f]];
		[_categoryTitleBox setEndColor:[NSColor colorWithCalibratedWhite:0.4f alpha:1.0f]];
		[_categoryTitleBox setLineWidth:1.0f];
		
		_pointsBox = [[RectangularBox alloc] init];
		[_pointsBox setSharpCorners:BoxCornerAll];
		[_pointsBox setStartColor:[NSColor colorWithCalibratedRed:46.0f/255.0f green:83.0f/255.0f blue:145.0f/255.0f alpha:1.0f]];
		[_pointsBox setEndColor:[NSColor colorWithCalibratedRed:92.0f/255.0f green:142.0f/255.0f blue:251.0f/255.0f alpha:1.0f]];
		[_pointsBox setLineWidth:1.0f];
		[_pointsBox setCornerRadius:10.0f];
		[_pointsBox setBorderColor:[NSColor colorWithCalibratedRed:0.2f green:0.2f blue:0.5f alpha:1.0f]];
		[_pointsBox setShadingDirection:BoxShadingHorizontal];
		
		_categoryTitleStrings = [[NSMutableArray alloc] init];
		_questionPointStrings = [[NSMutableArray alloc] init];
		_categories = nil;
		
		[self setSize:NSMakeSize(640.0f,480.0f)];
		
		unsigned int points;
		for( points = 100; points <= 500; points += 100 ) {
			StringTexture *aStringTexture = [[StringTexture alloc] initWithString:[[NSNumber numberWithInt:points] stringValue]
																		 withSize:_pointStringSize
																	 withFontSize:_pointStringSize.height];
			[aStringTexture setFont:[NSFont fontWithName:@"Helvetica-Bold" size:12.0f]];
			[aStringTexture setFontSize:_pointStringSize.height];
			[_questionPointStrings addObject:aStringTexture];
			[aStringTexture release];
		}
	}

	return self;
}

- (void)dealloc
{
	[_categoryTitleBox release];
	[_pointsBox release];
	
	[_categoryTitleStrings release];
	[_questionPointStrings release];

	[super dealloc];
}

- (void)setCategories:(NSArray *)newCategories
{
	[_categories release];
	_categories = [[NSArray alloc] initWithArray:[newCategories retain]];
	
	[_categoryTitleStrings removeAllObjects];
	
	NSEnumerator *categoryEnumerator = [newCategories objectEnumerator];
	TriviaCategory *aCategory;
	while( (aCategory = [categoryEnumerator nextObject]) ) {
		StringTexture *aStringTexture = [[StringTexture alloc] initWithString:[aCategory title] withSize:_titleStringSize withFontSize:_titleStringSize.height];
		[aStringTexture setColor:[NSColor colorWithCalibratedWhite:1.0f alpha:1.0f]];
		[aStringTexture fit];
		[_categoryTitleStrings addObject:aStringTexture];
		[aStringTexture release];
	}
}

#pragma mark Texture Scaling

- (void)setScale:(float)newScale
{
	_scale = newScale;
	// set new scale for other texture scaling objects
}

#define POINTPADDING ((NSSize){15.0f, -2.0f})
#define BOARDMARGINS ((NSSize){10.0f, 25.0f})
#define AVAILABLESIZE (NSMakeSize(_size.width - 2.0f*BOARDMARGINS.width - 4.0f*POINTPADDING.width, _size.height - 2.0f*BOARDMARGINS.height - 5.0f*POINTPADDING.height))
#define QUESTIONTITLESIZE (NSMakeSize(floorf(AVAILABLESIZE.width/5.0f),floorf(AVAILABLESIZE.height/5.0f)))
#define QUESTIONPOINTSIZE (NSMakeSize(QUESTIONTITLESIZE.width,floorf( (AVAILABLESIZE.height - QUESTIONTITLESIZE.height)/5.0f )))
#define TITLESTRINGSIZE 

- (void)setSize:(NSSize)newSize
{
	_size = newSize;
	// set new sizes for other texture scaling objects
	//NSSize boardPaddingSize = POINTPADDING;
	//NSSize boardMarginSize = BOARDMARGINS;
	NSSize availableSize = AVAILABLESIZE;
		/*NSMakeSize(_size.width - 2.0f*boardMarginSize.width - 4.0f*boardPaddingSize.width,
									  _size.height - 2.0f*boardMarginSize.height - 5.0f*boardPaddingSize.height); */
	
	_questionTitleSize = NSMakeSize(floorf(availableSize.width/5.0f),
										  floorf(availableSize.height/5.0f));
	_questionPointSize = NSMakeSize(_questionTitleSize.width,
										  floorf( (availableSize.height - _questionTitleSize.height)/5.0f ));
	
	[_categoryTitleBox setSize:_questionTitleSize];
	[_categoryTitleBox setCornerRadius:floorf(_questionTitleSize.height*0.2f)];
	
	[_pointsBox setSize:_questionPointSize];
	
	// strings
	_titleStringSize = NSMakeSize(floorf(_questionTitleSize.width*0.9f),
										floorf(_questionTitleSize.height*0.9f));
	NSEnumerator *categoryTitleEnumerator = [_categoryTitleStrings objectEnumerator];
	StringTexture *aCategoryTitle;
	while( (aCategoryTitle = [categoryTitleEnumerator nextObject]) ) {
		[aCategoryTitle setSize:_titleStringSize];
		[aCategoryTitle fit];
	}
	
	_pointStringSize = NSMakeSize(floorf(_questionPointSize.width*0.9f),
								  floorf(_questionPointSize.height*0.6f));
	NSEnumerator *pointEnumerator = [_questionPointStrings objectEnumerator];
	StringTexture *aPointString;
	while( (aPointString = [pointEnumerator nextObject]) ) {
		[aPointString setSize:_pointStringSize];
		[aPointString setFontSize:_pointStringSize.height];
	}
}
- (NSSize)size
{
	return _size;
}

- (void)buildTexture
{
	// build texture for other texture scaling objects
	[_categoryTitleBox buildTexture];
	[_pointsBox buildTexture];
	
	[_categoryTitleStrings makeObjectsPerformSelector:@selector(buildTexture)];
	[_questionPointStrings makeObjectsPerformSelector:@selector(buildTexture)];
}

- (void)draw
{
	float startHorizontal = BOARDMARGINS.width + (_size.width - 2.0f*BOARDMARGINS.width - (float)[_categoryTitleStrings count]*_questionTitleSize.width - (float)([_categoryTitleStrings count]-1)*POINTPADDING.width)/2.0f;
	NSSize boardSize;
	boardSize.width = [_categoryTitleStrings count]*_questionTitleSize.width + ([_categoryTitleStrings count]-1)*POINTPADDING.width;
	boardSize.height = _questionTitleSize.height + 5.0f*(_questionPointSize.height + POINTPADDING.height);
	
	glTranslatef(startHorizontal,_size.height-BOARDMARGINS.height-_questionTitleSize.height,0.0f);
	unsigned int categoryIndex;
	for( categoryIndex = 0; categoryIndex < [_categoryTitleStrings count]; categoryIndex++ ) {
		TriviaCategory *aCategory = [_categories objectAtIndex:categoryIndex];
		[_categoryTitleBox drawWithString:[_categoryTitleStrings objectAtIndex:categoryIndex]];
		
		glPushMatrix();
		glTranslatef(0.0f,-(POINTPADDING.height+_questionPointSize.height),0.0f);
		unsigned int questionIndex;
		for( questionIndex = 0; questionIndex < 5; questionIndex++ ) {
			StringTexture *aStringTexture = nil;
			if( ! [[[aCategory questions] objectAtIndex:questionIndex] used] )
				aStringTexture = [_questionPointStrings objectAtIndex:questionIndex];
			[_pointsBox drawWithString:aStringTexture];
			glTranslatef(0.0f,-(POINTPADDING.height+_questionPointSize.height),0.0f);
		}
		glPopMatrix();
		glTranslatef(_questionTitleSize.width+POINTPADDING.width,0.0f,0.0f);
	}
}

@end

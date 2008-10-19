//
//  TriviaSceneBoard.m
//  Questionable
//
//  Created by Nur Monson on 7/12/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TriviaSceneBoard.h"
#import "TriviaBoard.h"
#import "NSColor+Defaults.h"

@implementation TriviaSceneBoard

- (id)init
{
	if( (self = [super init]) ) {
		_scale = 1.0f;
		
		_categoryTitleBox = [[RectangularBox alloc] init];
		[_categoryTitleBox setSharpCorners:BoxCornerUpperRight | BoxCornerLowerRight];
		[_categoryTitleBox setLineWidth:1.0f];
		
		_pointsBox = [[RectangularBox alloc] init];
		[_pointsBox setSharpCorners:BoxCornerAll];
		[_pointsBox setLineWidth:1.0f];
		[_pointsBox setCornerRadius:10.0f];
		//[_pointsBox setShadingDirection:BoxShadingHorizontal];
		
		_shine = [[RectangularBox alloc] init];
		[_shine setStartColor:[NSColor colorWithCalibratedWhite:1.0f alpha:0.05f]];
		[_shine setEndColor:[NSColor colorWithCalibratedWhite:1.0f alpha:0.5f]];
		[_shine setSharpCorners:BoxCornerUpperRight | BoxCornerLowerRight];
		[_shine enableBorder:NO];
		
		[self updateColors];
		
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
	[_shine release];
	
	[_categoryTitleStrings release];
	[_questionPointStrings release];

	[super dealloc];
}

- (void)updateColors
{
	[_categoryTitleBox setStartColor:[NSColor colorWithCalibratedWhite:0.7f alpha:1.0f]];
	[_categoryTitleBox setEndColor:[NSColor colorWithCalibratedWhite:0.4f alpha:1.0f]];

	[_pointsBox setStartColor:[NSColor colorWithDifferenceHue:-.0385f saturation:0.0464f brightness:0.0186f]];
	[_pointsBox setEndColor:[NSColor colorWithDifferenceHue:0.0286f saturation:-0.0029f brightness:0.4343f]];
	[_pointsBox setBorderColor:[NSColor colorWithDifferenceHue:0.0238f saturation:-0.0364f brightness:-0.0500]];
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
		[aStringTexture setSize:_titleStringSize];
		[aStringTexture setScale:_scale];
		[aStringTexture setFontSize:_titleStringSize.height/2.0f];
		[aStringTexture fit];
		[_categoryTitleStrings addObject:aStringTexture];
		[aStringTexture release];
	}
	[self setSize:_size];
}

#pragma mark Texture Scaling

- (void)setScale:(float)newScale
{
	_scale = newScale;
	// set new scale for other texture scaling objects
	
	[_categoryTitleBox setScale:_scale];
	[_pointsBox setScale:_scale];
	[_shine setScale:_scale];
	
	NSEnumerator *categoryEnumerator = [_categoryTitleStrings objectEnumerator];
	StringTexture *aStringTexture;
	while( (aStringTexture = [categoryEnumerator nextObject]) )
		[aStringTexture setScale:_scale];
	
	NSEnumerator *pointEnumerator = [_questionPointStrings objectEnumerator];
	while( (aStringTexture = [pointEnumerator nextObject]) )
		[aStringTexture setScale:_scale];
}

#define POINTPADDING ((NSSize){-2.0f, 15.0f})
#define BOARDMARGINS ((NSSize){10.0f, 25.0f})
#define AVAILABLESIZE (NSMakeSize(_size.width - 2.0f*BOARDMARGINS.width - 4.0f*POINTPADDING.width, _size.height - 2.0f*BOARDMARGINS.height - 5.0f*POINTPADDING.height))

- (void)setSize:(NSSize)newSize
{
	_size = newSize;
	// set new sizes for other texture scaling objects
	NSSize availableSize = AVAILABLESIZE;
	
	_questionTitleSize = NSMakeSize(floorf(availableSize.width*0.3f),
									floorf(availableSize.height/5.0f));
	_questionPointSize = NSMakeSize(floorf( (availableSize.width - _questionTitleSize.width)/5.0f ),
									_questionTitleSize.height);
	
	[_categoryTitleBox setSize:_questionTitleSize];
	[_categoryTitleBox setCornerRadius:floorf(_questionTitleSize.height*0.2f)];
	
	[_pointsBox setSize:_questionPointSize];
	
	[_shine setSize:NSMakeSize(_questionTitleSize.width*0.95f,_questionTitleSize.height*0.25f)];
	[_shine setCornerRadius:[_categoryTitleBox cornerRadius]*0.8f];
	
	// strings
	_titleStringSize = NSMakeSize(floorf(_questionTitleSize.width*0.9f),
										floorf(_questionTitleSize.height*0.9f));
	NSEnumerator *categoryTitleEnumerator = [_categoryTitleStrings objectEnumerator];
	StringTexture *aCategoryTitle;
	while( (aCategoryTitle = [categoryTitleEnumerator nextObject]) ) {
		[aCategoryTitle setSize:_titleStringSize];
		[aCategoryTitle fit];
		//[aCategoryTitle setFontSize:_titleStringSize.height/5.0f];
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
	[_shine buildTexture];
	
	[_categoryTitleStrings makeObjectsPerformSelector:@selector(buildTexture)];
	[_questionPointStrings makeObjectsPerformSelector:@selector(buildTexture)];
}

- (void)draw
{
	float emptyHeight = _size.height;
	// space used by categories
	emptyHeight -= (float)[_categoryTitleStrings count]*_questionTitleSize.height;
	// space used by the space between categories
	emptyHeight -= (float)([_categoryTitleStrings count]-1)*POINTPADDING.height;
	
	NSSize boardSize;
	boardSize.width = [_categoryTitleStrings count]*_questionTitleSize.width + ([_categoryTitleStrings count]-1)*POINTPADDING.width;
	boardSize.height = _questionTitleSize.height + 5.0f*(_questionPointSize.height + POINTPADDING.height);
	
	glTranslatef(BOARDMARGINS.width, _size.height - emptyHeight/2.0f - _questionTitleSize.height,0.0f);
	unsigned int categoryIndex;
	for( categoryIndex = 0; categoryIndex < [_categoryTitleStrings count]; categoryIndex++ ) {
		TriviaCategory *aCategory = [_categories objectAtIndex:categoryIndex];
		[_categoryTitleBox drawWithString:[_categoryTitleStrings objectAtIndex:categoryIndex]];
		glPushMatrix();
		glTranslatef(([_categoryTitleBox size].width-[_shine size].width),([_categoryTitleBox size].height-[_shine size].height)*0.97f,0.0f);
		[_shine draw];
		glPopMatrix();
		
		glPushMatrix();
		glTranslatef((POINTPADDING.width+_questionTitleSize.width),0.0f,0.0f);
		unsigned int questionIndex;
		for( questionIndex = 0; questionIndex < 5; questionIndex++ ) {
			StringTexture *aStringTexture = nil;
			if( ! [[[aCategory questions] objectAtIndex:questionIndex] used] )
				aStringTexture = [_questionPointStrings objectAtIndex:questionIndex];
			[_pointsBox drawWithString:aStringTexture];
			glTranslatef((POINTPADDING.width+_questionPointSize.width),0.0f,0.0f);
		}
		glPopMatrix();
		glTranslatef(0.0f,-(_questionTitleSize.height+POINTPADDING.height),0.0f);
	}
}

@end

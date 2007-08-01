//
//  TriviaScenePlaceholder.m
//  Questionable
//
//  Created by Nur Monson on 7/13/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TriviaScenePlaceholder.h"


@implementation TriviaScenePlaceholder

- (id)init
{
	if( (self = [super init]) ) {
		_scale = 1.0f;
		
		_placeholderBox = [[RectangularBox alloc] init];
		[_placeholderBox setLineWidth:10.0f];
		[_placeholderBox setBorderColor:[NSColor colorWithCalibratedWhite:0.2f alpha:1.0f]];
		[_placeholderBox setStartColor:[NSColor colorWithCalibratedRed:0.5f green:0.7f blue:0.8f alpha:1.0f]];
		[_placeholderBox setEndColor:[NSColor colorWithCalibratedRed:0.1f green:0.7f blue:0.8f alpha:1.0f]];
		_questionmark = [[StringTexture alloc] initWithString:@"?" withSize:NSMakeSize(150.0f,150.0f) withFontSize:100.0f];
		[_questionmark setFont:[NSFont fontWithName:@"Helvetica-Bold" size:100.0f]];
		[_questionmark setColor:[NSColor colorWithCalibratedWhite:0.2f alpha:1.0f]];
		[_questionmark setFontSize:100.0f];
		
		_placeholderShine = [[RectangularBox alloc] init];
		[_placeholderShine enableBorder:NO];
		[_placeholderShine setSharpCorners:BoxCornerLowerLeft|BoxCornerLowerRight];
		[_placeholderShine setStartColor:[NSColor colorWithCalibratedWhite:1.0f alpha:0.05f]];
		[_placeholderShine setEndColor:[NSColor colorWithCalibratedWhite:1.0f alpha:0.5f]];
		
		[self setSize:NSMakeSize(640.0f,480.0f)];
	}

	return self;
}

- (void)dealloc
{
	[_placeholderBox release];
	[_questionmark release];
	[_placeholderShine release];

	[super dealloc];
}

#pragma mark Texture Scaling

- (void)setScale:(float)newScale
{
	if( newScale == _scale )
		return;
	
	_scale = newScale;
	
	[_placeholderBox setScale:newScale];
	[_placeholderShine setScale:newScale];
	[_questionmark setScale:newScale];
}
- (void)setSize:(NSSize)newSize
{
	if( NSEqualSizes(_size,newSize) )
		return;
	
	_size = newSize;
	
	[_placeholderBox setSize:NSMakeSize(_size.height*0.7f,_size.height*0.5f)];
	[_placeholderBox setCornerRadius:[_placeholderBox size].width/5.0f];
	[_placeholderBox setLineWidth:ceilf([_placeholderBox size].width*0.05f)];
	
	NSSize placeholderSize = [_placeholderBox size];
	[_placeholderShine setCornerRadius:[_placeholderBox cornerRadius]*0.68f];
	placeholderSize.width *= 0.87f;
	placeholderSize.height = [_placeholderShine cornerRadius] * 1.5f;
	[_placeholderShine setSize:placeholderSize];
	
	//TODO: make this width smaller (too much of a waste right now)
	[_questionmark setSize:_size];
	[_questionmark setFontSize:_size.height*0.5f];
}
- (NSSize)size
{
	return _size;
}

- (void)buildTexture
{
	[_placeholderBox buildTexture];
	[_questionmark buildTexture];
	[_placeholderShine buildTexture];
}
- (void)draw
{
	glTranslatef( (_size.width-[_placeholderBox size].width)/2.0f, (_size.height-[_placeholderBox size].height)/2.0f,0.0f);
	[_placeholderBox drawWithString:_questionmark];
	
	glPushMatrix();
	float xTranslate = ([_placeholderBox size].width - [_placeholderShine size].width)*0.5f;
	float yTranslate = ([_placeholderBox size].height - [_placeholderShine size].height)*0.98f;
	glTranslatef(xTranslate,yTranslate,0.0f);
	[_placeholderShine draw];
	glPopMatrix();
}

@end

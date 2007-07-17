//
//  TriviaSceneQA.m
//  Questionable
//
//  Created by Nur Monson on 7/13/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TriviaSceneQA.h"


@implementation TriviaSceneQA

- (id)init
{
	if( (self = [super init]) ) {
		_scale = 1.0f;
		
		_titleString = nil;
		_textString = nil;
		
		_QATitleBox = [[RectangularBox alloc] init];
		[_QATitleBox setStartColor:[NSColor colorWithCalibratedRed:0.2f green:0.25f blue:0.55f alpha:1.0f]];
		[_QATitleBox setEndColor:[NSColor colorWithCalibratedRed:0.3f green:0.35f blue:0.65f alpha:1.0f]];
		[_QATitleBox setSharpCorners:BoxCornerLowerLeft|BoxCornerLowerRight];
		[_QATitleBox setLineWidth:1.0f];
		_QATextBox = [[RectangularBox alloc] init];
		[_QATextBox setEndColor:[NSColor colorWithCalibratedRed:46.0f/255.0f green:83.0f/255.0f blue:145.0f/255.0f alpha:1.0f]];
		[_QATextBox setStartColor:[NSColor colorWithCalibratedRed:92.0f/255.0f green:142.0f/255.0f blue:251.0f/255.0f alpha:1.0f]];
		[_QATextBox setSharpCorners:BoxCornerUpperLeft|BoxCornerUpperRight];
		[_QATextBox setLineWidth:1.0f];
		
		_shine = [[RectangularBox alloc] init];
		[_shine setStartColor:[NSColor colorWithCalibratedWhite:1.0f alpha:0.05f]];
		[_shine setEndColor:[NSColor colorWithCalibratedWhite:1.0f alpha:0.5f]];
		[_shine setSharpCorners:BoxCornerLowerLeft | BoxCornerLowerRight];
		[_shine enableBorder:NO];
		
		_qTimer = [[ArcTimer alloc] initWithRadius:40.0f];
		
		[self setSize:NSMakeSize(640.0f,480.0f)];
	}

	return self;
}

- (void)dealloc
{
	[_QATitleBox release];
	[_QATextBox release];
	[_shine release];
	[_titleString release];
	[_textString release];
	
	[super dealloc];
}

#define SCALE_SIZE(a,b) ((NSSize){a.width*b,a.height*b})

- (void)setTitle:(NSString *)aTitle text:(NSString *)aText
{
	[_textString release];
	_textString = nil;
	[_titleString release];
	_titleString = nil;
	
	if( aText != nil ) {
		// width * 0.8
		_textString = [[StringTexture alloc] initWithString:aText withSize:SCALE_SIZE([_QATextBox size],0.9f) withFontSize:ceil([_QATextBox size].height/8.0f)];
		[_textString fit];
		if( [[_textString textContainer] fontSize] > [_QATextBox size].height/4.0f )
			[_textString setFontSize:ceilf([_QATextBox size].height/4.0f)];
		if( [[_textString textContainer] lineCount] > 1 )
			[[_textString textContainer] setAlignment:kTIPTextAlignmentLeft];
	}
	
	_titleString = [[StringTexture alloc] initWithString:aTitle withSize:[_QATitleBox size] withFontSize:ceilf([_QATitleBox size].height*0.7f)];
	[_titleString setColor:[NSColor colorWithCalibratedWhite:0.9f alpha:0.9f]];
	
	[_qTimer setProgress:1.0f];
}

- (void)setProgress:(float)newProgress
{
	[_qTimer setProgress:newProgress];
}

#pragma mark Texture Scaling

- (void)setScale:(float)newScale
{
	if( newScale == _scale )
		return;
	
	_scale = newScale;
	
	[_QATitleBox setScale:_scale];
	[_QATextBox setScale:_scale];
	[_shine setScale:_scale];
	[_titleString setScale:_scale];
	[_textString setScale:_scale];
	
	[_qTimer setScale:_scale];
}

#define BOARDMARGINS ((NSSize){10.0f, 25.0f})

- (void)setSize:(NSSize)newSize
{
	if( NSEqualSizes(newSize,_size) )
		return;
	
	_size = newSize;
	
	NSSize availableSize = NSMakeSize(_size.width-2.0f*BOARDMARGINS.width,
									  _size.height-2.0f*BOARDMARGINS.height);
	[_QATitleBox setSize:NSMakeSize(_size.width-2.0f*BOARDMARGINS.width, availableSize.height*0.2f)];
	[_QATitleBox setCornerRadius:[_QATitleBox size].height*0.4f];
	
	[_QATextBox setSize:NSMakeSize([_QATitleBox size].width,availableSize.height*0.8f)];
	[_QATextBox setCornerRadius:[_QATitleBox cornerRadius]];
	
	[_shine setSize:NSMakeSize([_QATitleBox size].width*0.95f,availableSize.height*0.1f)];
	[_shine setCornerRadius:[_QATitleBox cornerRadius]*0.8f];
	
	[_qTimer setScale:_size.height/480.0f];
	
	// resize strings
	
	if( _titleString != nil ) {
		[_titleString setSize:[_QATitleBox size]];
		[_titleString setFontSize:ceilf([_QATitleBox size].height*0.7f)];
	}
	if( _textString != nil ) {
		[_textString setSize:NSMakeSize([_QATextBox size].width*0.9f,[_QATextBox size].height*0.8f)];
		//[_textString setSize:SCALE_SIZE([_QATextBox size],0.8f)];
		[_textString fit];
		if( [_textString fontSize] > [_QATextBox size].height/4.0f )
			[_textString setFontSize:ceilf([_QATextBox size].height/4.0f)];
	}
	
}
- (NSSize)size
{
	return _size;
}

- (void)buildTexture
{
	[_QATitleBox buildTexture];
	[_QATextBox buildTexture];
	[_shine buildTexture];
	[_titleString buildTexture];
	[_textString buildTexture];
}
- (void)draw
{
	glTranslatef(BOARDMARGINS.width,_size.height-BOARDMARGINS.height-[_QATitleBox size].height,0.0f);
	[_QATitleBox drawWithString:_titleString];
	if( [_qTimer progress] != 0.0f ) {
		glPushMatrix();
		glTranslatef([_QATitleBox size].height/2.0f,[_QATitleBox size].height/2.0f,0.0f);
		glScalef(_size.height/480.0f,_size.height/480.0f,1.0f);
		[_qTimer draw];
		glPopMatrix();
	}
	glPushMatrix();
	glTranslatef(0.0f,-[_QATextBox size].height+[_QATextBox lineWidth],0.0f);
	[_QATextBox drawWithString:_textString];
	glPopMatrix();
	
	glTranslatef(([_QATitleBox size].width-[_shine size].width)/2.0f,([_QATitleBox size].height-[_shine size].height)*0.95f,0.0f);
	[_shine draw];
}

@end

//
//  ArcTimer.m
//  Questionable
//
//  Created by Nur Monson on 7/5/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "ArcTimer.h"


@implementation ArcTimer

- (id)init
{
	if( (self = [super init]) ) {
		_bgTexture = 0;
		_radius = 10.0f;
		
		_bgColor = [[NSColor whiteColor] retain];
		
		_textureSize = 0.0f;
		_dirtyTexture = YES;
	}

	return self;
}

- (void)deleteTextures
{
	if( _bgTexture == 0 )
		return;
	
	glDeleteTextures(1,&_bgTexture);
	_bgTexture = 0;
}

- (void)dealloc
{
	[_bgColor release];
	[self deleteTextures];

	[super dealloc];
}

- (id)initWithRadius:(float)radius{
	if( (self = [super init]) ) {
		[self setRadius:radius];
		_dirtyTexture = YES;
	}
	
	return self;
}

- (void)generateTextures
{
	[self deleteTextures];
	
	float circleRadius = ceilf(_radius/5.0f);
	_textureSize = ceilf(circleRadius + 1.0f)*2.0f;
	
	void *bitmapData = calloc( (int)_textureSize*(int)_textureSize*4, 1 );
	if( bitmapData == NULL ) {
		printf("could not allocate bitmap data\n");
		return;
	}
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bitmapContext = CGBitmapContextCreate(bitmapData,(int)_textureSize,(int)_textureSize,8,(int)_textureSize*4,colorSpace,kCGImageAlphaPremultipliedLast);
	if( bitmapContext == NULL ) {
		printf("Could not create bitmapContext\n");
		return;
	}
	CGColorSpaceRelease(colorSpace);
	
	// draw BG Texture
	CGContextClearRect(bitmapContext,CGRectMake(0.0f,0.0f,_textureSize,_textureSize));
	
	CGContextAddArc(bitmapContext,_textureSize/2.0f,_textureSize/2.0f,circleRadius,0.0f,M_PI*2.0f,1);
	CGContextSetRGBFillColor(bitmapContext,1.0f,1.0f,1.0f,1.0f);
	CGContextClosePath(bitmapContext);
	CGContextFillPath(bitmapContext);
	
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glGenTextures(1, &_bgTexture);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _bgTexture);
	glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGBA8, _textureSize, _textureSize, 0, GL_RGBA, GL_UNSIGNED_BYTE, bitmapData);
	glDisable(GL_TEXTURE_RECTANGLE_EXT);
	
	// draw background texture
	free(bitmapData);
	_dirtyTexture = NO;
}

- (void)setRadius:(float)newRadius
{
	if( newRadius == _radius )
		return;
	
	_radius = newRadius;
	_dirtyTexture = YES;
}
- (float)radius
{
	return _radius;
}

- (void)setBGColor:(NSColor *)newColor
{
	if( newColor == _bgColor )
		return;
	
	[_bgColor release];
	_bgColor = [newColor retain];
}
- (NSColor *)bgColor
{
	return _bgColor;
}

//const float dots

- (void)drawPercentage:(float)percentage
{
	if( _dirtyTexture )
		[self generateTextures];
	
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _bgTexture);
	glColor4f(1.0f,1.0f,1.0f,0.8f);
	
	glPushAttrib(GL_COLOR_BUFFER_BIT);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	
	float currentPercentage = 0.0f;
	int i;
	for( i=0; i<8 && currentPercentage<percentage; i++ ) {
		glPushMatrix();
		glRotatef(i*360.0f/8.0f,0.0f,0.0f,1.0f);
		glTranslatef(0.0f,_radius - _textureSize/2.0f,0.0f);
		glBegin(GL_TRIANGLE_STRIP); {
			glTexCoord2f(0.0f,0.0f); glVertex2f(-_textureSize/2.0f,-_textureSize/2.0f);
			glTexCoord2f(_textureSize,0.0f); glVertex2f(_textureSize/2.0f,-_textureSize/2.0f);
			glTexCoord2f(0.0f,_textureSize); glVertex2f(-_textureSize/2.0f,_textureSize/2.0f);
			glTexCoord2f(_textureSize,_textureSize); glVertex2f(_textureSize/2.0f,_textureSize/2.0f);
		} glEnd();
		glPopMatrix();
		currentPercentage += 1.0f/8.0f;
	}
	glPopAttrib();
}
@end

//
//  TextureCanvas.m
//  Questionable
//
//  Created by Nur Monson on 7/5/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TextureCanvas.h"


@implementation TextureCanvas

- (id)init
{
	if( (self = [super init]) ) {
		_texture = 0;
		_size = NSZeroSize;
		_scale = 1.0f;
		
		_dirtyTexture = YES;
	}

	return self;
}

- (void)deleteTexture
{
	if( _texture == 0 )
		return;
	
	glDeleteTextures(1,&_texture);
	_texture = 0;
}

- (void)dealloc
{
	[self deleteTexture];
	
	[super dealloc];
}

- (void)setScale:(float)newScale
{
	if( newScale == _scale )
		return;
	
	_scale = newScale;
	_dirtyTexture = YES;
	_textureSize = NSMakeSize(ceilf(_scale*_size.width)+1.0f,ceilf(_scale*_size.height)+1.0f);
}
- (float)scale
{
	return _scale;
}

- (void)setSize:(NSSize)newSize
{
	if( NSEqualSizes(newSize,_size) )
		return;
	
	_size = newSize;
	_dirtyTexture = YES;
	_textureSize = NSMakeSize(ceilf(_scale*_size.width)+1.0f,ceilf(_scale*_size.height)+1.0f);
}
- (NSSize)size
{
	return _size;
}
- (NSSize)textureSize
{
	return _textureSize;
}

- (void)set
{
	glPushAttrib(GL_COLOR_BUFFER_BIT);
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _texture);
	glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
}
- (void)unset
{
	glPopAttrib();
}

- (void)buildTexture
{
	[self deleteTexture];
	
	void *bitmapData = calloc( (int)_textureSize.width*(int)_textureSize.height*4, 1 );
	if( bitmapData == NULL ) {
		printf("could not allocate bitmap data\n");
		return;
	}
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bitmapContext = CGBitmapContextCreate(bitmapData,(int)_textureSize.width,(int)_textureSize.height,8,(int)_textureSize.width*4,colorSpace,kCGImageAlphaPremultipliedLast);
	if( bitmapContext == NULL ) {
		printf("Could not create bitmapContext\n");
		return;
	}
	CGColorSpaceRelease(colorSpace);
	
	// draw BG Texture
	CGContextClearRect(bitmapContext,CGRectMake(0.0f,0.0f,_textureSize.width,_textureSize.height));

	[self drawTexture:bitmapContext];
	
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glGenTextures(1, &_texture);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _texture);
	glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGBA8, _textureSize.width, _textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, bitmapData);
	glDisable(GL_TEXTURE_RECTANGLE_EXT);
	
	free(bitmapData);
	CGContextRelease(bitmapContext);
	_dirtyTexture = NO;
}
- (void)drawTexture:(CGContextRef)cxt
{
	// do nothing. Subclasses do all the work in here.
}

- (void)draw
{
	if( _dirtyTexture )
		[self buildTexture];
	
	[self set];	
	
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _texture);
	glBegin(GL_TRIANGLE_STRIP); {
		glTexCoord2f(0.0f,0.0f); glVertex2f(0.0f,0.0f);
		glTexCoord2f(_textureSize.width,0.0f); glVertex2f(_size.width,0.0f);
		glTexCoord2f(0.0f,_textureSize.height); glVertex2f(0.0f,_size.height);
		glTexCoord2f(_textureSize.width,_textureSize.height); glVertex2f(_size.width,_size.height);
	} glEnd();
	
	[self unset];
}
- (void)drawCentered
{
	glPushMatrix();
	glTranslatef(-_size.width/2.0f,-_size.height,0.0f);
	[self draw];
	glPopMatrix();
}

@end

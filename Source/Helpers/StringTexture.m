//
//  StringTexture.m
//  CocoaAndOpenGL
//
//  Created by Nur Monson on 2/21/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "StringTexture.h"

#define glReportError()\
{\
	GLenum error=glGetError();\
		if(GL_NO_ERROR!=error)\
		{\
			printf("GL error at %s:%d: %s\n",__FILE__,__LINE__,(char*)gluErrorString(error));\
		}\
}\

@implementation StringTexture

- (id)init
{
	if( (self = [super init]) ) {
		_text = nil;
		_textureID = 0;
		_textureSize = NSZeroSize;
		[self setColor:[NSColor colorWithCalibratedWhite:0.0f alpha:1.0f]];
		
		_scale = 1.0f;
		_dirtyTexture = YES;
	}

	return self;
}

- (void)deleteTexture
{
	if( _textureID == 0 )
		return;
	
	glDeleteTextures(1,&_textureID);
	_textureID = 0;
	_dirtyTexture = YES;
}

- (void)dealloc
{
	[self deleteTexture];
	[_text release];
	[_textColor release];		

	[super dealloc];
}

- (id)initWithString:(NSString *)aString withSize:(NSSize)theSize withFontSize:(float)fontSize
{
	if( aString == nil )
		return nil;
	
	if( (self = [self init]) ) {
		_text = [[TIPTextContainer containerWithString:aString] retain];
		[self setSize:theSize];
		[self setFontSize:fontSize];
		[self setColor:[NSColor colorWithCalibratedWhite:0.0f alpha:1.0f]];
	}
	
	return self;
}

- (void)calculateTextureSize
{
	NSSize boxSize = NSMakeSize(ceilf(_size.width*_scale),ceilf(_size.height*_scale));
	NSSize textSize = [_text containerSize];
	textSize.width = ceilf(textSize.width);
	textSize.height = ceilf(textSize.height);
	if( textSize.height > boxSize.height )
		textSize = boxSize;
	
	_textureSize = textSize;
}

- (void)setString:(NSString *)newString
{
	[_text setText:newString];
	[self calculateTextureSize];
	_dirtyTexture = YES;
}

- (void)fit
{
	[_text fitTextInRect:NSMakeRect(0.0f,0.0f,_size.width*_scale,_size.height*_scale)];
	_fontSize = [_text fontSize]/_scale;
	[self calculateTextureSize];
	_dirtyTexture = YES;
}

- (TIPTextContainer *)textContainer
{
	return _text;
}

- (void)setColor:(NSColor *)newColor
{
	[_textColor release];
	_textColor = [[newColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
}

- (void)setFont:(NSFont *)newFont
{
	[_text setFont:newFont];
	_dirtyTexture = YES;
}

- (void)setFontSize:(float)newFontSize
{
	_fontSize = newFontSize;
	[_text setFontSize:newFontSize*_scale];
	[self calculateTextureSize];
	_dirtyTexture = YES;
}
- (float)fontSize
{
	return _fontSize;
}

- (void)generateAlphaOnlyTexture
{
	if( !_dirtyTexture )
		return;
	
	[self deleteTexture];
		
	int paddedWidth = (((int)_textureSize.width/4)+1)*4;
	void *bitmapData = calloc( paddedWidth*(int)_textureSize.height, 1 );
	if( bitmapData == NULL ) {
		printf("could not allocate bitmap data\n");
		return;
	}
	
	CGContextRef bitmapContext = CGBitmapContextCreate(bitmapData, (int)_textureSize.width,(int)_textureSize.height,8,paddedWidth,NULL,kCGImageAlphaOnly);
	if( bitmapContext == NULL ) {
		printf("Could not create bitmapContext\n");
		return;
	}
	[_text drawTextInRect:NSMakeRect(0.0f,0.0f,_textureSize.width,_textureSize.height) inContext:bitmapContext];
	
	CGContextRelease( bitmapContext );
	
	//_textureSize = textSize;
	
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glGenTextures (1, &_textureID);
	glBindTexture (GL_TEXTURE_RECTANGLE_EXT, _textureID);
	glTexImage2D (GL_TEXTURE_RECTANGLE_EXT, 0, GL_ALPHA8, paddedWidth, (int)_textureSize.height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, bitmapData);
	glReportError()
	glDisable(GL_TEXTURE_RECTANGLE_EXT);
	
	free(bitmapData);
	
	_dirtyTexture = NO;
}

- (NSSize)naturalSize
{
	return _textureSize;
}

- (NSSize)usableSize
{
	return NSMakeSize(ceilf(_textureSize.width/_scale),ceilf(_textureSize.height/_scale));
}

- (void)draw
{
	if ( _dirtyTexture )
		[self generateAlphaOnlyTexture];
	
	if ( _textureID == 0)
		return;
	
	NSSize usableSize = [self usableSize];
	
	glPushAttrib(GL_COLOR_BUFFER_BIT);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	glPushMatrix();
	float red,green,blue,alpha;
	[_textColor getRed:&red green:&green blue:&blue alpha:&alpha];
	glColor4f(red,green,blue,alpha);
	
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _textureID);
	glBegin(GL_QUADS); {
		glTexCoord2f(0.0f, _textureSize.height); // draw upper left in world coordinates
		glVertex2f(0.0f, 0.0f);
		
		glTexCoord2f(0.0f, 0.0f); // draw lower left in world coordinates
		glVertex2f(0.0f, usableSize.height);
		
		glTexCoord2f(_textureSize.width, 0.0f); // draw upper right in world coordinates
		glVertex2f(usableSize.width, usableSize.height);
		
		glTexCoord2f(_textureSize.width, _textureSize.height); // draw lower right in world coordinates
		glVertex2f(usableSize.width, 0.0f);
	} glEnd ();
	
	glDisable(GL_TEXTURE_RECTANGLE_EXT);
	glPopMatrix();
	glPopAttrib();
}

- (void)buildTexture
{
	[self generateAlphaOnlyTexture];
}
- (NSSize)size
{
	return _size;
}
- (void)setSize:(NSSize)newSize
{
	if( NSEqualSizes(newSize,_size) )
		return;
	
	_size = newSize;
	[_text setWidth:_size.width*_scale];
	[self calculateTextureSize];
	_dirtyTexture = YES;
}

- (void)setScale:(float)newScale
{
	if( newScale == _scale )
		return;
	
	_scale = newScale;
	
	[self setFontSize:_fontSize];
	[_text setWidth:_size.width*_scale];
	[self calculateTextureSize];
	_dirtyTexture = YES;
}

@end

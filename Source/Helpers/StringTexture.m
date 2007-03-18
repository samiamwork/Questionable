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
}

- (void)dealloc
{
	[self deleteTexture];
	[_text release];
	[_textColor release];

	[super dealloc];
}

- (id)initWithString:(NSString *)aString withWidth:(float)textureWidth withFontSize:(float)fontSize
{
	if( aString == nil )
		return nil;
	
	if( (self = [self init]) ) {
		_text = [[TIPTextContainer containerWithString:aString] retain];
		[_text setWidth:textureWidth];
		[_text setFontSize:fontSize];
		[_text setColor:[NSColor colorWithCalibratedWhite:1.0f alpha:1.0f]];
	}
	
	return self;
}

- (void)setColor:(NSColor *)newColor
{
	[_textColor release];
	_textColor = [newColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	[_textColor retain];
}

- (void)setFont:(NSFont *)newFont
{
	[_text setFont:newFont];
	_dirtyTexture = YES;
}

- (void)generateAlphaOnlyTexture
{
	[self deleteTexture];
	
	NSSize textSize = [_text containerSize];
	textSize.width = truncf(textSize.width);
	textSize.height = truncf(textSize.height);
	
	void *bitmapData = calloc( (int)textSize.width*(int)textSize.height, 1 );
	if( bitmapData == NULL ) {
		printf("could not allocate bitmap data\n");
		return;
	}
	
	CGContextRef bitmapContext = CGBitmapContextCreate(bitmapData,(int)textSize.width,(int)textSize.height,8,(int)textSize.width,NULL,kCGImageAlphaOnly);
	if( bitmapContext == NULL ) {
		printf("Could not create bitmapContext\n");
		return;
	}
	[_text drawTextInRect:NSMakeRect(0.0f,0.0f,textSize.width,textSize.height) inContext:bitmapContext];
	CGContextRelease( bitmapContext );
	
	_textureSize = textSize;
	
	unsigned char *convertedData = (unsigned char *)calloc( (int)_textureSize.width*(int)_textureSize.height * 2, 1 );
	unsigned char *originalData = (unsigned char *)bitmapData;
	int pixelIndex;
	int pixelCount = (int)_textureSize.width * (int)_textureSize.height;
	for( pixelIndex = 0; pixelIndex < pixelCount; pixelIndex++ ) {
		convertedData[pixelIndex*2+0] = 0xFF;
		convertedData[pixelIndex*2+1] = originalData[pixelIndex];
	}
	
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glGenTextures (1, &_textureID);
	glBindTexture (GL_TEXTURE_RECTANGLE_EXT, _textureID);
	glTexImage2D (GL_TEXTURE_RECTANGLE_EXT, 0, GL_ALPHA8, _textureSize.width, _textureSize.height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, bitmapData);
	//glTexImage2D(GL_TEXTURE_RECTANGLE_EXT,0,GL_LUMINANCE4_ALPHA4, _textureSize.width,_textureSize.height,0,GL_LUMINANCE_ALPHA,GL_UNSIGNED_BYTE,convertedData);
	glReportError()
	glDisable(GL_TEXTURE_RECTANGLE_EXT);
	
	free(convertedData);
	free(bitmapData);
	
	_dirtyTexture = NO;
}

- (void)generateTexture
{
	NSImage * image;
	NSBitmapImageRep * bitmap;
	
	[self deleteTexture];

	NSSize textSize = [_text containerSize];

	image = [[NSImage alloc] initWithSize:textSize];
	[image lockFocus]; {
		CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
		if( cxt == NULL )
			printf("NULL cxt! for drawing container\n");
		[_text drawTextInRect:NSMakeRect(0.0f,0.0f,textSize.width,textSize.height) inContext:cxt];
		bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect (0.0f, 0.0f, textSize.width, textSize.height)];
	} [image unlockFocus];

	_textureSize = [bitmap size];
	
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glGenTextures (1, &_textureID);
	glBindTexture (GL_TEXTURE_RECTANGLE_EXT, _textureID);
	glTexImage2D (GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGBA, _textureSize.width, _textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, [bitmap bitmapData]);
	glReportError()
	glDisable(GL_TEXTURE_RECTANGLE_EXT);
	[bitmap release];
	[image release];
	
	_dirtyTexture = NO;
}

- (NSSize)naturalSize
{
	return _textureSize;
}

- (void)drawAtPoint:(NSPoint)aPoint withWidth:(float)width
{
	if ( _dirtyTexture )
		[self generateAlphaOnlyTexture];
		//[self generateTexture];
	
	if ( _textureID == 0)
		return;
	
	NSSize drawnSize = _textureSize;
	drawnSize.width = width;
	drawnSize.height *= width/_textureSize.width;
	
	glPushMatrix();
	float red,green,blue,alpha;
	[_textColor getRed:&red green:&green blue:&blue alpha:&alpha];
	glColor4f(red,green,blue,alpha);
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _textureID);
	//glTexEnvi(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glBegin(GL_QUADS); {
		glTexCoord2f(0.0f, _textureSize.height); // draw upper left in world coordinates
		glVertex2f(aPoint.x, aPoint.y);
		
		glTexCoord2f(0.0f, 0.0f); // draw lower left in world coordinates
		glVertex2f(aPoint.x, aPoint.y + drawnSize.height);
		
		glTexCoord2f(_textureSize.width, 0.0f); // draw upper right in world coordinates
		glVertex2f(aPoint.x + drawnSize.width, aPoint.y + drawnSize.height);
		
		glTexCoord2f(_textureSize.width, _textureSize.height); // draw lower right in world coordinates
		glVertex2f(aPoint.x + drawnSize.width, aPoint.y);
	} glEnd ();
	
	glDisable(GL_TEXTURE_RECTANGLE_EXT);
	glPopMatrix();
}

- (void)drawCenteredInSize:(NSSize)aSize
{
	if ( _textureID == 0 )
		//[self generateAlphaOnlyTexture];
		[self generateTexture];
	
	if ( _textureID == 0)
		return;
	
	NSPoint offset;
	offset.x = (aSize.width - _textureSize.width)/2.0f;
	offset.y = (aSize.height - _textureSize.height)/2.0f;
	[self drawAtPoint:offset withWidth:_textureSize.width];
}

@end

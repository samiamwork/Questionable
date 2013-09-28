//
//  RectangularBox.m
//  CocoaAndOpenGL
//
//  Created by Nur Monson on 2/22/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "RectangularBox.h"

#define VERTEXCOUNT_BORDER 32
#define VERTEXCOUNT_HOLE 4

@implementation RectangularBox

- (id)init
{
	if( (self = [super init]) ) {
		_borderTexture = 0;
		_bgTexture = 0;
		_cornerRadius = 0.0f;
		_lineWidth = 1.0f;
		_boxSize = NSZeroSize;
		_scale = 1.0f;
		
		_dirtyTexture = YES;
		_dirtyVerticies = YES;
		
		_sharpCorners = BoxCornerNone;
		_shadingDirection = BoxShadingVertical;
		
		_isBorderEnabled = YES;
		
		[self setStartColor:[NSColor colorWithCalibratedWhite:0.7f alpha:1.0f]];
		[self setEndColor:[NSColor colorWithCalibratedWhite:0.5f alpha:1.0f]];
		[self setBorderColor:[NSColor colorWithCalibratedWhite:0.8f alpha:1.0f]];
		
		_vertexArray = (fullVertex2 *)malloc( sizeof(fullVertex2)*(VERTEXCOUNT_BORDER+ VERTEXCOUNT_HOLE));
	}
	
	return self;
}

- (void)deleteTexture
{
	if( _borderTexture == 0 )
		return;
	
	glDeleteTextures(1,&_borderTexture);
	_borderTexture = 0;
	
	glDeleteTextures(1,&_bgTexture);
	_bgTexture = 0;
}

- (void)dealloc
{
	free( _vertexArray );
	
	[self deleteTexture];
	
	[super dealloc];
}

- (id)initWithSize:(NSSize)boxSize withRadius:(float)cornerRadius withLineWidth:(float)lineWidth
{	
	if( (self = [self init]) ) {
		[self setSize:boxSize];
		[self setCornerRadius:cornerRadius];
		[self setLineWidth:lineWidth];
	}
	
	return self;
}

- (void)setSharpCorners:(BoxCorner)newCorners
{
	if( newCorners == _sharpCorners )
		return;
	
	_sharpCorners = newCorners;
	_dirtyVerticies = YES;
}

- (void)setShadingDirection:(BoxShadingDirection)newShadingDirection
{
	if( newShadingDirection == _shadingDirection )
		return;
	
	_shadingDirection = newShadingDirection;
	_dirtyVerticies = YES;
}

- (void)setStartColor:(NSColor *)newColor
{
	NSColor *rgbColor = [newColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	CGFloat red, green, blue, alpha;
	[rgbColor getRed:&red green:&green blue:&blue alpha:&alpha];
	_startColor.red   = red;
	_startColor.green = green;
	_startColor.blue  = blue;
	_startColor.alpha = alpha;
	_dirtyVerticies = YES;
}

- (void)setEndColor:(NSColor *)newColor
{
	NSColor *rgbColor = [newColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	CGFloat red, green, blue, alpha;
	[rgbColor getRed:&red green:&green blue:&blue alpha:&alpha];
	_endColor.red   = red;
	_endColor.green = green;
	_endColor.blue  = blue;
	_endColor.alpha = alpha;
	_dirtyVerticies = YES;
}

- (void)setBorderColor:(NSColor *)newColor
{
	NSColor *rgbColor = [newColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	CGFloat red, green, blue, alpha;
	[rgbColor getRed:&red green:&green blue:&blue alpha:&alpha];
	_borderColor.red   = red;
	_borderColor.green = green;
	_borderColor.blue  = blue;
	_borderColor.alpha = alpha;
	_dirtyVerticies = YES;
}

- (void)setSize:(NSSize)newSize
{
	_boxSize = newSize;
	_dirtyVerticies = YES;
}
- (NSSize)size
{
	return _boxSize;
}

- (void)setCornerRadius:(float)newRadius
{
	if( newRadius < 0.0f )
		newRadius = 0.0f;
	
	_cornerRadius = newRadius;
	_dirtyTexture = YES;
	_dirtyVerticies = YES;
}
- (float)cornerRadius
{
	return _cornerRadius;
}

- (void)setLineWidth:(float)newWidth
{
	if( newWidth < 1.0f )
		newWidth = 1.0f;
	
	_lineWidth = newWidth;
	_dirtyTexture = YES;
}
- (float)lineWidth
{
	return _lineWidth;
}

- (void)enableBorder:(BOOL)willEnable
{
	_isBorderEnabled = willEnable;
}
- (BOOL)isBorderEnabled
{
	return _isBorderEnabled;
}

- (void)buildTexture
{
	[self deleteTexture];
	
	_textureSize = ceilf((_cornerRadius + _lineWidth/2.0f)*_scale);
	
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
	
	// draw Border Texture
	CGContextClearRect(bitmapContext,CGRectMake(0.0f,0.0f,_textureSize,_textureSize));
	CGContextScaleCTM(bitmapContext,_scale,_scale);
	
	CGContextSetRGBStrokeColor(bitmapContext,1.0f,1.0f,1.0f,1.0f);
	CGContextMoveToPoint(bitmapContext,_cornerRadius,0.0f);
	CGContextAddArcToPoint(bitmapContext,_cornerRadius,_cornerRadius,0.0f,_cornerRadius,_cornerRadius);
	CGContextSetLineWidth(bitmapContext,_lineWidth);
	CGContextStrokePath(bitmapContext);
	
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glGenTextures(1, &_borderTexture);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _borderTexture);
	glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGBA8, _textureSize, _textureSize, 0, GL_RGBA, GL_UNSIGNED_BYTE, bitmapData);
	glDisable(GL_TEXTURE_RECTANGLE_EXT);

	// draw background texture
	CGContextClearRect(bitmapContext,CGRectMake(0.0f,0.0f,_textureSize/_scale,_textureSize/_scale));

	CGContextSetRGBFillColor(bitmapContext,1.0f,1.0f,1.0f,1.0f);
	CGContextMoveToPoint(bitmapContext,0.0f,0.0f);
	CGContextAddLineToPoint(bitmapContext,_cornerRadius,0.0f);
	CGContextAddArcToPoint(bitmapContext,_cornerRadius,_cornerRadius,0.0f,_cornerRadius,_cornerRadius);
	CGContextClosePath(bitmapContext);
	CGContextFillPath(bitmapContext);
	
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glGenTextures (1, &_bgTexture);
	glBindTexture (GL_TEXTURE_RECTANGLE_EXT, _bgTexture);
	glTexImage2D (GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGBA8, _textureSize, _textureSize, 0, GL_RGBA, GL_UNSIGNED_BYTE, bitmapData);
	glDisable(GL_TEXTURE_RECTANGLE_EXT);
	
	CGContextRelease( bitmapContext );
	free(bitmapData);
	_dirtyTexture = NO;
}

#define blendComponent(a,b,p) ((((b) - (a))*(p)) + (a))

color4 blendColors( color4 color1, color4 color2, float position )
{
	color4 newColor;
	
	newColor.red = blendComponent(color1.red, color2.red, position);
	newColor.green = blendComponent(color1.green, color2.green, position);
	newColor.blue = blendComponent(color1.blue, color2.blue, position);
	newColor.alpha = blendComponent(color1.alpha, color2.alpha, position);
	
	return newColor;
}

void setArrayElement( fullVertex2 **fullVertex, vertex2 vert, texture2 tex, color4 color )
{
	(*fullVertex)->vertex = vert;
	(*fullVertex)->texture = tex;
	(*fullVertex)->color = color;
	
	(*fullVertex)++;
}

- (void)generateVertexArray
{
	float xPoints[4] = { 0.0f, _textureSize/_scale, _boxSize.width-_textureSize/_scale, _boxSize.width };
	float yPoints[4] = { 0.0f, _textureSize/_scale, _boxSize.height-_textureSize/_scale, _boxSize.height };
	color4 midColor1 = blendColors( _startColor, _endColor, yPoints[1]/_boxSize.height );
	color4 midColor2 = blendColors( _startColor, _endColor, yPoints[2]/_boxSize.height );

	if( _boxSize.width < _cornerRadius*2.0f ) {
		switch( (int)_sharpCorners ) {
			case BoxCornerUpperLeft|BoxCornerLowerLeft:
				xPoints[2] = xPoints[1];
				break;
			case BoxCornerUpperRight|BoxCornerLowerRight:
			default:
				xPoints[1] = xPoints[2];
				break;
		}
	}
	if( _boxSize.height < _cornerRadius*2.0f ) {
		switch( (int)_sharpCorners ) {
			case BoxCornerUpperLeft|BoxCornerUpperRight:
				yPoints[2] = yPoints[1];
				break;
			case BoxCornerLowerLeft|BoxCornerLowerRight:
			default:
				yPoints[1] = yPoints[2];
				break;
		}
	}
	
	if( BoxShadingVertical ) {
		midColor1 = blendColors( _startColor, _endColor, yPoints[1]/_boxSize.height );
		midColor2 = blendColors( _startColor, _endColor, yPoints[2]/_boxSize.height );
	} else {
		midColor1 = blendColors( _startColor, _endColor, xPoints[1]/_boxSize.width );
		midColor2 = blendColors( _startColor, _endColor, xPoints[2]/_boxSize.width );
	}
	
	color4 *colors[4] = { &_startColor, &midColor1, &midColor2, &_endColor };
	color4 *currentColor;
	
	fullVertex2 *vertexPointer = _vertexArray;
	
	//upper right
	if( _sharpCorners & BoxCornerUpperRight ) {
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 2];
		setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[2]}, (texture2){0.0f,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 3];
		setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[3]}, (texture2){_textureSize,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 3 : 3];
		setArrayElement( &vertexPointer, (vertex2){xPoints[3],yPoints[3]}, (texture2){_textureSize,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 3 : 2];
		setArrayElement( &vertexPointer, (vertex2){xPoints[3],yPoints[2]}, (texture2){_textureSize,_textureSize}, *currentColor );
	} else {
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 2];
		setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[2]}, (texture2){0.0f,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 3];
		setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[3]}, (texture2){0.0f,0.0f}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 3 : 3];
		setArrayElement( &vertexPointer, (vertex2){xPoints[3],yPoints[3]}, (texture2){_textureSize,0.0f}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 3 : 2];
		setArrayElement( &vertexPointer, (vertex2){xPoints[3],yPoints[2]}, (texture2){_textureSize,_textureSize}, *currentColor );
	}
	
	//right
	if( _boxSize.height > _cornerRadius*2.0f ) {
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 1];
		setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[1]}, (texture2){0.0f,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 3 : 1];
		setArrayElement( &vertexPointer, (vertex2){xPoints[3],yPoints[1]}, (texture2){_textureSize,_textureSize}, *currentColor );
		
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 3 : 2];
		setArrayElement( &vertexPointer, (vertex2){xPoints[3],yPoints[2]}, (texture2){_textureSize,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 2];
		setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[2]}, (texture2){0.0f,_textureSize}, *currentColor );
	}
	
	//lower right
	if( _sharpCorners & BoxCornerLowerRight ) {
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 1];
		setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[1]}, (texture2){0.0f,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 3 : 1];
		setArrayElement( &vertexPointer, (vertex2){xPoints[3],yPoints[1]}, (texture2){0.0f,0.0f}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 3 : 0];
		setArrayElement( &vertexPointer, (vertex2){xPoints[3],yPoints[0]}, (texture2){0.0f,0.0f}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 0];
		setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[0]}, (texture2){0.0f,0.0f}, *currentColor );
	} else {
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 1];
		setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[1]}, (texture2){0.0f,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 3 : 1];
		setArrayElement( &vertexPointer, (vertex2){xPoints[3],yPoints[1]}, (texture2){_textureSize,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 3 : 0];
		setArrayElement( &vertexPointer, (vertex2){xPoints[3],yPoints[0]}, (texture2){_textureSize,0.0f}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 0];
		setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[0]}, (texture2){0.0f,0.0f}, *currentColor );
	}
	
	//lower
	if( _boxSize.width > _cornerRadius*2.0f ) {
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 0];
		setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[0]}, (texture2){0.0f,0.0f}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 0];
		setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[0]}, (texture2){0.0f,0.0f}, *currentColor );
		
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 1];
		setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[1]}, (texture2){0.0f,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 1];
		setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[1]}, (texture2){0.0f,_textureSize}, *currentColor );
	}
	
	//lower left
	if( _sharpCorners & BoxCornerLowerLeft ) {
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 1];
		setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[1]}, (texture2){0.0f,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 0];
		setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[0]}, (texture2){0.0f,0.0f}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 0 : 0];
		setArrayElement( &vertexPointer, (vertex2){xPoints[0],yPoints[0]}, (texture2){0.0f,0.0f}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 0 : 1];
		setArrayElement( &vertexPointer, (vertex2){xPoints[0],yPoints[1]}, (texture2){0.0f,0.0f}, *currentColor );
	} else {
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 1];
		setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[1]}, (texture2){0.0f,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 0];
		setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[0]}, (texture2){0.0f,0.0f}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 0 : 0];
		setArrayElement( &vertexPointer, (vertex2){xPoints[0],yPoints[0]}, (texture2){_textureSize,0.0f}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 0 : 1];
		setArrayElement( &vertexPointer, (vertex2){xPoints[0],yPoints[1]}, (texture2){_textureSize,_textureSize}, *currentColor );
	}
	
	//left
	if( _boxSize.height > _cornerRadius*2.0f ) {
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 0 : 1];
		setArrayElement( &vertexPointer, (vertex2){xPoints[0],yPoints[1]}, (texture2){_textureSize,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 1];
		setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[1]}, (texture2){0.0f,_textureSize}, *currentColor );
		
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 2];
		setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[2]}, (texture2){0.0f,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 0 : 2];
		setArrayElement( &vertexPointer, (vertex2){xPoints[0],yPoints[2]}, (texture2){_textureSize,_textureSize}, *currentColor );
	}
	
	//upper left
	if( _sharpCorners & BoxCornerUpperLeft ) {
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 2];
		setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[2]}, (texture2){0.0f,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 0 : 2];
		setArrayElement( &vertexPointer, (vertex2){xPoints[0],yPoints[2]}, (texture2){_textureSize,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 0 : 3];
		setArrayElement( &vertexPointer, (vertex2){xPoints[0],yPoints[3]}, (texture2){_textureSize,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 3];
		setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[3]}, (texture2){_textureSize,_textureSize}, *currentColor );
	} else {
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 2];
		setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[2]}, (texture2){0.0f,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 0 : 2];
		setArrayElement( &vertexPointer, (vertex2){xPoints[0],yPoints[2]}, (texture2){_textureSize,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 0 : 3];
		setArrayElement( &vertexPointer, (vertex2){xPoints[0],yPoints[3]}, (texture2){_textureSize,0.0f}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 3];
		setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[3]}, (texture2){0.0f,0.0f}, *currentColor );
	}
	
	//upper
	if( _boxSize.width > _cornerRadius*2.0f ) {
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 2];
		setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[2]}, (texture2){0.0f,_textureSize}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 2];
		setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[2]}, (texture2){0.0f,_textureSize}, *currentColor );
		
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 3];
		setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[3]}, (texture2){0.0f,0.0f}, *currentColor );
		currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 3];
		setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[3]}, (texture2){0.0f,0.0f}, *currentColor );
	}
	
	// hole
	currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 1];
	setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[1]}, (texture2){0.0f,_textureSize}, *currentColor );
	currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 1];
	setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[1]}, (texture2){0.0f,_textureSize}, *currentColor );
	currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 2 : 2];
	setArrayElement( &vertexPointer, (vertex2){xPoints[2],yPoints[2]}, (texture2){0.0f,_textureSize}, *currentColor );
	currentColor = colors[_shadingDirection == BoxShadingHorizontal ? 1 : 2];
	setArrayElement( &vertexPointer, (vertex2){xPoints[1],yPoints[2]}, (texture2){0.0f,_textureSize}, *currentColor );
	
	_dirtyVerticies = NO;
}

- (void)setScale:(float)newScale
{
	if( newScale == _scale )
		return;
	
	_scale = newScale;
	_dirtyTexture = YES;
	_dirtyVerticies = YES;
}

- (void)draw
{
	if( _dirtyTexture )
		[self buildTexture];
	if ( _borderTexture == 0)
		return;
	
	if( _dirtyVerticies )
		[self generateVertexArray];
	
	glPushMatrix();
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glTexCoordPointer( 2,GL_FLOAT,sizeof(fullVertex2),&_vertexArray->texture);
	glVertexPointer( 2,GL_FLOAT,sizeof(fullVertex2),&_vertexArray->vertex);
	glColorPointer( 4,GL_FLOAT,sizeof(fullVertex2),&_vertexArray->color);
	
	// draw background
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _bgTexture);
	int objectIndex;
	
	//the number of objects to draw depends on if we're wide/high
	// enough to need the plain rectangular spacers.
	int objectCount = 9;
	if( _boxSize.width < _cornerRadius*2.0f )
		objectCount -= 2;
	if( _boxSize.height < _cornerRadius*2.0f )
		objectCount -= 2;
	if( objectCount == 5 )
		objectCount --;
	
	glPushAttrib(GL_COLOR_BUFFER_BIT);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	for( objectIndex = 0; objectIndex < objectCount; objectIndex++ )
		glDrawArrays( GL_TRIANGLE_FAN, objectIndex*4, 4 );
	glPopAttrib();
	
	// if we drew the hole for the background don't draw it here
	if( objectCount != 4 )
		objectCount--;
	// draw border
	if( _isBorderEnabled ) {
		glColor4f(_borderColor.red,_borderColor.green,_borderColor.blue,_borderColor.alpha);
		glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _borderTexture);
		glDisableClientState(GL_COLOR_ARRAY);
		for( objectIndex = 0; objectIndex < objectCount; objectIndex++ )
			glDrawArrays( GL_TRIANGLE_FAN, objectIndex*4, 4 );
	}
	
	glDisable(GL_TEXTURE_RECTANGLE_EXT);
	glPopMatrix();
	
}
- (void)drawWithString:(StringTexture *)aStringTexture
{
	[self draw];
	// draw String
	if( aStringTexture == nil )
		return;
	
	NSSize stringSize = [aStringTexture usableSize];
	NSPoint offset = NSMakePoint((_boxSize.width-stringSize.width)/2.0f,(_boxSize.height-stringSize.height)/2.0f);
	glPushMatrix();
	glTranslatef(offset.x,offset.y,0.0f);
	[aStringTexture draw];
	glPopMatrix();
}

@end

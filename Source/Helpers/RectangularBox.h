//
//  RectangularBox.h
//  CocoaAndOpenGL
//
//  Created by Nur Monson on 2/22/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/OpenGL.h>
#import "StringTexture.h"

typedef struct color4 {
	GLfloat red;
	GLfloat green;
	GLfloat blue;
	GLfloat alpha;
} color4;

typedef struct vertex2 {
	GLfloat x;
	GLfloat y;
} vertex2;

typedef struct texture2 {
	GLfloat s;
	GLfloat t;
} texture2;

typedef struct fullVertex2 {
	vertex2 vertex;
	texture2 texture;
	color4 color;
} fullVertex2;

typedef enum BoxCorner {
	BoxCornerNone = 0,
	BoxCornerUpperRight = 1,
	BoxCornerLowerRight = 2,
	BoxCornerLowerLeft = 4,
	BoxCornerUpperLeft = 8,
	BoxCornerAll = 15
} BoxCorner;

typedef enum BoxShadingDirection {
	BoxShadingHorizontal,
	BoxShadingVertical
} BoxShadingDirection;

@interface RectangularBox : NSObject {
	GLuint _borderTexture;
	GLuint _bgTexture;
		
	color4 _startColor;
	color4 _endColor;
	color4 _borderColor;

	float _cornerRadius;
	float _lineWidth;
	NSSize _boxSize;
	float _textureSize;
	
	BoxCorner _sharpCorners;
	BoxShadingDirection _shadingDirection;
	
	fullVertex2 *_vertexArray;
	
	BOOL _dirtyTexture;
	BOOL _dirtyVerticies;
}

- (id)initWithSize:(NSSize)boxSize withRadius:(float)cornerRadius withLineWidth:(float)lineWidth;
- (void)generateTextures;
- (void)drawWithString:(StringTexture *)aStringTexture;

- (void)setSharpCorners:(BoxCorner)newCorners;
- (void)setShadingDirection:(BoxShadingDirection)newShadingDirection;
- (void)setSize:(NSSize)newSize;
- (void)setCornerRadius:(float)newRadius;
- (void)setLineWidth:(float)newWidth;

- (void)setStartColor:(NSColor *)newColor;
- (void)setEndColor:(NSColor *)newColor;
- (void)setBorderColor:(NSColor *)newColor;

@end

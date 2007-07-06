//
//  TextureCanvas.h
//  Questionable
//
//  Created by Nur Monson on 7/5/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/OpenGL.h>

@interface TextureCanvas : NSObject {
	GLuint _texture;
	NSSize _size;
	NSSize _textureSize;
	float _scale;

	BOOL _dirtyTexture;
}

- (void)setScale:(float)newScale;
- (float)scale;
- (void)setSize:(NSSize)newSize;
- (NSSize)size;
- (NSSize)textureSize;

/*
 * Binds the texture for use by openGL.
 * Must call unbind after done.
 */
- (void)set;
- (void)unset;

- (void)buildTexture;
- (void)drawTexture:(CGContextRef)cxt;

- (void)draw;
- (void)drawCentered;
@end

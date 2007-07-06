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

@protocol TextureScaling
- (void)setScale:(float)newScale;
- (void)setSize:(NSSize)newSize;
- (NSSize)size;

- (void)buildTexture;
- (void)draw;
@end

@interface TextureCanvas : NSObject <TextureScaling> {
	GLuint _texture;
	NSSize _size;
	NSSize _textureSize;
	float _scale;

	BOOL _dirtyTexture;
}

- (NSSize)textureSize;
-  (float)scale;
/*
 * Binds the texture for use by openGL.
 * Must call unbind after done.
 */
- (void)set;
- (void)unset;

- (void)drawTexture:(CGContextRef)cxt;
- (void)drawCentered;
@end

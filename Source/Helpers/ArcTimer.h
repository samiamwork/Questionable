//
//  ArcTimer.h
//  Questionable
//
//  Created by Nur Monson on 7/5/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/OpenGL.h>
#import "RectangularBox.h"

@interface ArcTimer : NSObject {
	GLuint _bgTexture;
	NSColor *_bgColor;
	
	float _radius;
	float _textureSize;
	
	BOOL _dirtyTexture;
}

- (id)initWithRadius:(float)radius;
- (void)generateTextures;

- (void)setRadius:(float)newRadius;
- (float)radius;
- (void)setBGColor:(NSColor *)newColor;
- (NSColor *)bgColor;

- (void)drawPercentage:(float)percentage;
@end

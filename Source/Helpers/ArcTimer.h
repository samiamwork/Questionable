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
#import "TextureCanvas.h"

@interface DotTexture : TextureCanvas {
}
@end

@interface ArcTimer : NSObject <TextureScaling> {
	NSColor *_bgColor;
	float _radius;
	
	DotTexture *_dot;
}

- (id)initWithRadius:(float)radius;

- (void)setRadius:(float)newRadius;
- (float)radius;
- (void)setBGColor:(NSColor *)newColor;
- (NSColor *)bgColor;

- (void)drawPercentage:(float)percentage;
@end

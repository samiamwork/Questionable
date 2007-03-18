//
//  StringTexture.h
//  CocoaAndOpenGL
//
//  Created by Nur Monson on 2/21/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLContext.h>
#import "TIPTextContainer.h"


@interface StringTexture : NSObject {
	GLuint _textureID;
	NSSize _textureSize;
	NSColor *_textColor;
	
	TIPTextContainer *_text;
	BOOL _dirtyTexture;
}

- (id)initWithString:(NSString *)aString withWidth:(float)textureWidth withFontSize:(float)fontSize;
- (void)setFont:(NSFont *)newFont;
- (void)setColor:(NSColor *)newColor;
- (void)generateTexture;
- (void)drawAtPoint:(NSPoint)aPoint withWidth:(float)width;
- (void)drawCenteredInSize:(NSSize)aSize;
- (NSSize)naturalSize;
@end

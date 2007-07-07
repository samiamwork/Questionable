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
#import "TextureCanvas.h"

@interface StringTexture : NSObject <TextureScaling> {
	GLuint _textureID;
	NSSize _textureSize;
	NSColor *_textColor;
	
	float _scale;
	NSSize _size;
	float _fontSize;
	
	TIPTextContainer *_text;
	BOOL _dirtyTexture;
}

- (id)initWithString:(NSString *)aString withSize:(NSSize)theSize withFontSize:(float)fontSize;
- (void)setString:(NSString *)newString;
- (void)setFont:(NSFont *)newFont;
- (void)setFontSize:(float)newFontSize;
- (float)fontSize;
- (NSSize)usableSize;
- (void)setColor:(NSColor *)newColor;
//- (void)drawCenteredInSize:(NSSize)aSize;
- (void)fit;
- (TIPTextContainer *)textContainer;

- (void)draw;
- (void)buildTexture;
- (NSSize)size;
- (void)setSize:(NSSize)newSize;
- (void)setScale:(float)newScale;
@end

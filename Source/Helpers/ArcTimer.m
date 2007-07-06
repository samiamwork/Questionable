//
//  ArcTimer.m
//  Questionable
//
//  Created by Nur Monson on 7/5/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "ArcTimer.h"

@implementation DotTexture
- (void)drawTexture:(CGContextRef)cxt
{
	float radius = [self size].width*[self scale]/2.0f;
	CGContextAddArc(cxt,[self textureSize].width/2.0f,[self textureSize].height/2.0f,radius,0.0f,M_PI*2.0f,1);
	CGContextSetRGBFillColor(cxt,1.0f,1.0f,1.0f,1.0f);
	CGContextClosePath(cxt);
	CGContextFillPath(cxt);
}
@end

@implementation ArcTimer

- (id)init
{
	if( (self = [super init]) ) {
		_radius = 10.0f;
		
		_bgColor = [[NSColor whiteColor] retain];
		_dot = [[DotTexture alloc] init];
		[_dot setSize:NSMakeSize(1.0f,1.0f)];
	}

	return self;
}

- (void)dealloc
{
	[_bgColor release];
	[_dot release];

	[super dealloc];
}

- (id)initWithRadius:(float)radius{
	if( (self = [super init]) ) {
		_dot = [[DotTexture alloc] init];
		[self setRadius:radius];
	}
	
	return self;
}

- (void)setScale:(float)newScale
{
	[_dot setScale:newScale];
}
- (void)buildTexture
{
	[_dot buildTexture];
}

- (void)setRadius:(float)newRadius
{
	if( newRadius == _radius )
		return;
	
	_radius = newRadius;
	[_dot setSize:NSMakeSize(ceil(_radius/2.5f),ceil(_radius/2.5f))];
}
- (float)radius
{
	return _radius;
}

- (void)setSize:(NSSize)newSize
{
	[self setRadius:MIN(newSize.width,newSize.height)/2.0f];
}
- (NSSize)size
{
	return NSMakeSize(_radius*2.0f,_radius*2.0f);
}

- (void)setBGColor:(NSColor *)newColor
{
	if( newColor == _bgColor )
		return;
	
	[_bgColor release];
	_bgColor = [newColor retain];
}
- (NSColor *)bgColor
{
	return _bgColor;
}

- (void)setProgress:(float)newProgress
{
	_progress = newProgress;
}
- (float)progress
{
	return _progress;
}

//const float dots

- (void)draw
{
	glColor4f(0.3f,0.3f,0.3f,0.3f);
	
	float currentProgress = 0.0f;
	int i;
	for( i=0; i<8 && currentProgress<_progress; i++ ) {
		glPushMatrix();
		glRotatef(i*360.0f/8.0f,0.0f,0.0f,1.0f);
		glTranslatef(0.0f,_radius - [_dot size].width/2.0f,0.0f);
		
		[_dot drawCentered];
		
		glPopMatrix();
		currentProgress += 1.0f/8.0f;
	}

}

@end

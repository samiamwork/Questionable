//
//  TriviaBoardOpenGLView.m
//  Questionable
//
//  Created by Nur Monson on 2/20/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TriviaBoardOpenGLView.h"


@implementation TriviaBoardOpenGLView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		
		NSOpenGLPixelFormatAttribute windowedAttributes[] = {
			NSOpenGLPFAWindow,
			NSOpenGLPFAAccelerated,
			NSOpenGLPFADoubleBuffer,
			NSOpenGLPFAColorSize, 24,
			NSOpenGLPFAAlphaSize, 8,
			0 };
		
		_windowedPixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:windowedAttributes] autorelease];
		_windowedContext = [[NSOpenGLContext alloc] initWithFormat:_windowedPixelFormat shareContext:nil];
		
		if( !_windowedContext ) {
			printf("error creating windowed OpenGL contex\n");
			[self dealloc];
			return nil;
		}
		
		long vsync = 1;
		[_windowedContext setValues:&vsync forParameter:NSOpenGLCPSwapInterval];
		
		_preserveTargetAspectRatio = YES;
		_targetAspectRatio = 640.0f/480.0f;
		_needsReshape = NO;
		_isFirstFrame = YES;
    }
	
    return self;
}

- (void)dealloc
{
	[_windowedContext release];
	[_windowedPixelFormat release];

	[super dealloc];
}


- (void)awakeFromNib
{
	//[self reshape];
}

- (void)reshape
{
	_needsReshape = YES;
	
	NSSize thisSize = [self bounds].size;
	_contextSize = thisSize;
	
	if( thisSize.width != _contextSize.width || thisSize.height != _contextSize.height ) {
		_targetSize = thisSize;
		
		float targetWidth = thisSize.height*_targetAspectRatio;
		float targetHeight = thisSize.width/_targetAspectRatio;
		
		if( targetWidth < thisSize.width )
			_targetSize.width = targetWidth;
		else if( targetHeight < thisSize.height )
			_targetSize.height = targetHeight;
	}
}

- (NSRect)fitRect:(NSRect)inputRect inRect:(NSRect)inRect
{
	NSRect outputRect;
	outputRect.origin = inRect.origin;
	float rectAspectRatio = inRect.size.width/inRect.size.height;
	float imageAspectRatio = inputRect.size.width/inputRect.size.height;
	
	float zoom;
	if( imageAspectRatio < rectAspectRatio ) {
		zoom = inRect.size.height/inputRect.size.height;
		outputRect.size.height = inRect.size.height;
		outputRect.size.width = roundf( inputRect.size.width*zoom);
		outputRect.origin.x += roundf( (inRect.size.width - outputRect.size.width)/2.0f );
	} else {
		zoom = inRect.size.width/inputRect.size.width;
		outputRect.size.height = roundf( inputRect.size.height*zoom);
		outputRect.size.width = inRect.size.width;
		outputRect.origin.y += roundf( (inRect.size.height - outputRect.size.height)/2.0f );
	}
	
	return outputRect;
}

- (void)doReshape
{
	_contextSize = [self bounds].size;
	
	_targetSize = _contextSize;
	
	float targetWidth = _contextSize.height*_targetAspectRatio;
	float targetHeight = _contextSize.width/_targetAspectRatio;
	
	if( targetWidth < _contextSize.width )
		_targetSize.width = targetWidth;
	else if( targetHeight < _contextSize.height )
		_targetSize.height = targetHeight;
	
	[_windowedContext update];
	glViewport(0.0f, 0.0f, _contextSize.width, _contextSize.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	if( !_preserveTargetAspectRatio ) {
		glOrtho(0.0f, _contextSize.width, 0.0f, _contextSize.height, 300.0f, -300.0f);
	} else if( _targetSize.width < _contextSize.width ) {
		float dx = (_contextSize.width - _targetSize.width)/2.0f;
		glOrtho(0.0f-dx, _targetSize.width+dx, 0.0f, _contextSize.height, 300.0f, -300.0f);
	} else if( _targetSize.height < _contextSize.height ) {
		float dy = (_contextSize.height - _targetSize.height)/2.0f;
		glOrtho(0.0f, _contextSize.width, 0.0f-dy, _targetSize.height+dy, 300.0f, -300.0f);
	} else {
		glOrtho(0.0f, _contextSize.width, 0.0f, _contextSize.height, 300.0f, -300.0f);
	}
	
	glMatrixMode(GL_MODELVIEW);
	
	_needsReshape = NO;
	
	[self setNeedsDisplay:YES];
}

- (void)firstFrameSetup
{
	[_windowedContext setView:self];
	[_windowedContext makeCurrentContext];
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
	
	_contextSize = NSZeroSize;
	
	_isFirstFrame = NO;
	_needsReshape = YES;
}

- (void)drawRect:(NSRect)rect
{
	if( _isFirstFrame )
		[self firstFrameSetup];
	
	NSSize boundSize = [self bounds].size;
	if( _contextSize.width != boundSize.width || _contextSize.height != boundSize.height )
		[self doReshape];
	
	glClearColor(0.5f,0.0f,0.0f,1.0f);
	glClear( GL_COLOR_BUFFER_BIT );

	glColor4f( 1.0f,0.0f,0.5f,1.0f );
	glBegin(GL_TRIANGLE_FAN); {
		glVertex2f(0.0f,0.0f);
		glVertex2f(_targetSize.width,0.0f);
		glVertex2f(_targetSize.width,_targetSize.height);
		glVertex2f(0.0f,_targetSize.height);
	} glEnd();
	 
	[_windowedContext flushBuffer];
}

@end

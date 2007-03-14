//
//  TriviaBoardOpenGLView.h
//  Questionable
//
//  Created by Nur Monson on 2/20/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import <QuartzCore/QuartzCore.h>


@interface TriviaBoardOpenGLView : NSView {
	NSOpenGLContext *_windowedContext;
	NSOpenGLPixelFormat *_windowedPixelFormat;
	
	float _targetAspectRatio;
	BOOL _preserveTargetAspectRatio;
	BOOL _needsReshape;
	BOOL _isFirstFrame;
	
	NSSize _targetSize;
	NSSize _contextSize;
}

@end

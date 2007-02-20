//
//  TIPScreenSelectionView.m
//  TIPScreenSelectionView
//
//  Created by Nur Monson on 9/18/06.
//  Copyright theidiotproject 2006 . All rights reserved.
//

#import "TIPScreenSelectionView.h"

#define NSRectToCGRect(a)	(*(CGRect*)&a)

@implementation TIPScreenSelectionView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		
		if( ![self getScreenConfiguration] )
			return nil;
		[self setSelectedScreen:[NSScreen mainScreen]];
		
		screenToView = [NSAffineTransform transform];
		[screenToView retain];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(screenParametersChanged)
													 name:@"NSApplicationDidChangeScreenParametersNotification"
												   object:nil];
		
		delegate = nil;
		image = [NSApp applicationIconImage];
	}
	return self;
}

- (void)awakeFromNib
{
	[self setSelectedScreen:[NSScreen mainScreen]];
}
	
- (NSRect)transformRect:(NSRect)rect withTransform:(NSAffineTransform*)trans
{
	rect.size = [trans transformSize:rect.size];
	rect.origin = [trans transformPoint:rect.origin];
	
	return rect;
}

- (BOOL)getScreenConfiguration
{
	NSEnumerator *enumerator;
	NSScreen *screen;
	NSRect rect;
	
	totalBounds.origin.x = 0.0f;
	totalBounds.origin.y = 0.0f;
	totalBounds.size.height = 0.0f;
	totalBounds.size.width = 0.0f;
	
	allScreens = [NSScreen screens];
	if([allScreens count] == 0)
		return false;
	
	enumerator = [allScreens objectEnumerator];
	
	while( (screen = [enumerator nextObject]) ) {
		rect = [screen frame];
		
		if(rect.origin.x + rect.size.width > totalBounds.origin.x + totalBounds.size.width)
			totalBounds.size.width = rect.origin.x + rect.size.width - totalBounds.origin.x;
		if(rect.origin.y + rect.size.height > totalBounds.origin.y + totalBounds.size.height)
			totalBounds.size.height = rect.origin.y + rect.size.height - totalBounds.origin.y;
		if(rect.origin.x < totalBounds.origin.x) {
			totalBounds.size.width = totalBounds.origin.x + totalBounds.size.width - rect.origin.x;
			totalBounds.origin.x = rect.origin.x;
		}
		if(rect.origin.y < totalBounds.origin.y) {
			totalBounds.size.height = totalBounds.origin.y + totalBounds.size.height - rect.origin.y;
			totalBounds.origin.y = rect.origin.y;
		}
	}
	
	return true;
}

- (void)createTransformMatrix:(CGContextRef)cxt
{
	NSRect bounds = [self bounds];
	NSRect transformedTotalBounds;
	NSAffineTransform *trans = [NSAffineTransform transform];
	NSAffineTransform *center = [NSAffineTransform transform];
	float scale;
	
	if(screenToView)
		[screenToView release];
	screenToView = [[NSAffineTransform alloc] init];
	
	[screenToView translateXBy:-totalBounds.origin.x yBy:-totalBounds.origin.y];
	
	// Find the largest dimension of the totalBounds so it all will fit in the view
	if( totalBounds.size.width > totalBounds.size.height )
		scale = bounds.size.width/totalBounds.size.width;
	else
		scale = bounds.size.height/totalBounds.size.height;
	
	[trans scaleBy:scale*0.9f];
	[screenToView appendTransform:trans];
	
	transformedTotalBounds.size = [screenToView transformSize:totalBounds.size];
	transformedTotalBounds.origin = [screenToView transformPoint:totalBounds.origin];
	
	[center translateXBy:-transformedTotalBounds.size.width/2 + bounds.size.width/2
						   yBy:-transformedTotalBounds.size.height/2 + bounds.size.height/2];
	
	[screenToView appendTransform:center];
	
}

- (void)screenParametersChanged
{
	[self setNeedsDisplay:TRUE];
}

- (void)drawImageInRect:(NSRect)aRect
{
	if( image == nil )
		return;
	
	NSSize imageSize = [image size];
	float heightQuotient = imageSize.height / aRect.size.height;
	float widthQuotient = imageSize.width / aRect.size.width;
	
	NSRect imageRect = aRect;
	if(heightQuotient > widthQuotient) {
		imageRect.size.width = imageSize.width/heightQuotient;
		imageRect.size.height = imageSize.height/heightQuotient;
		
		imageRect.origin.x += (aRect.size.width-imageRect.size.width)/2.0f;
	} else {
		imageRect.size.width = imageSize.width/widthQuotient;
		imageRect.size.height = imageSize.height/widthQuotient;
		
		imageRect.origin.y += (aRect.size.height-imageRect.size.height)/2.0f;
	}
	
	[image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
}

static float borderColor[] = {0.2f, 0.2f, 0.6f, 1.0f};
static float hilightColor[] = {0.7f, 0.2f, 0.2f, 1.0f};

- (void)drawRect:(NSRect)rect
{	
	NSRect bounds = [self bounds];
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	
	CGContextSaveGState(cxt);
	if( ![self getScreenConfiguration] )
		return;
	
	NSPoint rP = NSMakePoint(NSMidX(bounds),0.0f);
	TIPMutableGradientRef bgGradientRef = TIPMutableGradientCreate();
	TIPGradientAddRGBColorStop( bgGradientRef,0.0f, 1.0f,1.0f,1.0f,1.0f);
	TIPGradientAddRGBColorStop( bgGradientRef,1.0f, 0.8f,0.8f,0.8f,1.0f);
	TIPGradientRadialFillRect( cxt, bgGradientRef, *(CGRect *)&bounds,*(CGPoint *)&rP,sqrtf(rP.x*rP.x + bounds.size.height*bounds.size.height));
	
	[self createTransformMatrix:cxt];
	
	NSSize lineSize;
	lineSize.width = lineSize.height = 20.0f;
	lineSize = [screenToView transformSize:lineSize];
	CGContextSetLineWidth(cxt, lineSize.width);
	
	TIPMutableGradientRef screenGradientRef = TIPMutableGradientCreate();
	TIPGradientAddRGBColorStop( screenGradientRef,0.0f, 0.9f,0.9f,1.0f,1.0f);
	TIPGradientAddRGBColorStop( screenGradientRef,1.0f, 0.8f,0.8f,1.0f,1.0f);
	
	NSScreen *menuScreen = [allScreens objectAtIndex:0];
	CGContextSetLineWidth( cxt, 4.0f);
	CGContextSetRGBFillColor( cxt, 1.0f,1.0f,1.0f,1.0f );
	NSEnumerator *enumerator = [allScreens objectEnumerator];
	NSScreen *aScreen;
	while( (aScreen = [enumerator nextObject]) ) {
		CGContextSaveGState(cxt);
		
		NSRect aScreenRect = [aScreen frame];
		aScreenRect.size = [screenToView transformSize:aScreenRect.size];
		aScreenRect.origin = [screenToView transformPoint:aScreenRect.origin];
		aScreenRect = NSIntegralRect(aScreenRect);
		
		TIPGradientAxialFillRect( cxt, screenGradientRef, *(CGRect *)&aScreenRect,85.0f);
		CGContextClipToRect( cxt, *(CGRect *)&aScreenRect);
		
		if( aScreen == menuScreen ) {
			NSRect menuRect, remainderRect;
			NSSize menuSize = { 0.0f, 80.0f };
			menuSize = [screenToView transformSize: menuSize];
			NSDivideRect( aScreenRect, &menuRect, &remainderRect, menuSize.height, NSMaxYEdge );
			CGContextFillRect( cxt, *(CGRect *)&menuRect );
		}
		
		if( aScreen == selectedScreen ) {
			CGContextSetRGBStrokeColor(cxt, hilightColor[0],hilightColor[1],hilightColor[2],hilightColor[3]);
			if( image != nil )
				[self drawImageInRect:NSInsetRect(aScreenRect,10.0f,10.0f)];
		} else
			CGContextSetRGBStrokeColor(cxt, borderColor[0], borderColor[1], borderColor[2], borderColor[3]);
		
		CGContextStrokeRect(cxt, NSRectToCGRect(aScreenRect) );
		
		CGContextRestoreGState(cxt);
	}
	
	CGContextRestoreGState(cxt);
}

- (id)delegate
{
	return delegate;
}

- (void)setDelegate:(id)mDelegate
{
	delegate = mDelegate;
}

- (NSImage *)image
{
	return image;
}
- (void)setImage:(NSImage *)anImage
{
	if( anImage == image )
		return;
	
	[image release];
	image = [anImage retain];
}


- (NSScreen *)getSelectedScreen
{
	return selectedScreen;
}

- (void)setSelectedScreen:(NSScreen *)aScreen
{
	selectedScreen = aScreen;
	
	if(delegate && [delegate respondsToSelector:@selector(selectedScreenChanged)])
		[delegate selectedScreenChanged:selectedScreen];
}

BOOL isPointInRect(NSPoint point, NSRect rect)
{
	if((point.x < rect.origin.x) || (point.y < rect.origin.y))
		return NO;
	if((point.x > rect.origin.x + rect.size.width) || (point.y > rect.origin.y + rect.size.height))
		return NO;
	
	return YES;
}	

- (void)mouseDown:(NSEvent *)theEvent
{
	NSEnumerator *enumerator = [allScreens objectEnumerator];
	NSScreen *aScreen;
	NSRect rect;
	
	// find the screen clicked (if any) keeping in mind that at least one
	// screen must always be selected.
	NSPoint where = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	while( (aScreen = [enumerator nextObject]) ) {
		rect = [aScreen frame];
		rect.origin = [screenToView transformPoint:rect.origin];
		rect.size = [screenToView transformSize:rect.size];
		//printRect(rect);
		
		if( isPointInRect(where, rect) && aScreen != selectedScreen) {
			//printf("new screen!\n");
			[self setSelectedScreen:aScreen];
			[self setNeedsDisplay:TRUE];
		}
	}
}

@end

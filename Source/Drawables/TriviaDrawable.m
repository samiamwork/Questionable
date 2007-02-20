//
//  TriviaDrawablePlaceholder.m
//  TriviaPlayer
//
//  Created by Nur Monson on 10/7/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaDrawable.h"


@implementation TriviaDrawable

- (id)init
{
	if( (self = [super init]) ) {
		
		layer = NULL;
		image = NULL;
		imageBytes = NULL;
		layerSize = NSMakeSize(0.0f,0.0f);
		cgImageSize = layerSize;
		
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	if( layer )
		CGLayerRelease( layer );
	
	if( image )
		CGImageRelease(image);
	
	if( imageBytes )
		free( imageBytes );
}

- (CGLayerRef)getLayer
{
	return layer;
}

- (CGLayerRef)makeLayerForSize:(NSSize)theSize withContext:(CGContextRef)theContext
{
	if( theSize.width == layerSize.width && theSize.height == layerSize.height )
		return layer;
	
	if( layer )
		CGLayerRelease( layer );
	
	layer = CGLayerCreateWithContext(theContext,*(CGSize *)&theSize, NULL);
	if( layer == NULL ) {
		printf("Could not create layer for drawable!\n");
		return NULL;
	}
	
	layerSize = theSize;
	CGContextRef layerContext = CGLayerGetContext( layer );
	if( layerContext == NULL ) {
		printf("Could not get CGContextRef for layer!\n");
		return NULL;
	}
	
	[self drawInRect:NSMakeRect(0.0f,0.0f,layerSize.width,layerSize.height) inContext:layerContext];
	
	layerSize = theSize;
	
	return layer;
}

- (CGImageRef)makeCGImageForSize:(NSSize)theSize
{
	/*
	if( theSize.width == cgImageSize.width && theSize.height == cgImageSize.height )
		return image;
	*/
	if( image ) {
		CGImageRelease( image );
		image = NULL;
	}
	
	if( imageBytes ) {
		free( imageBytes );
		imageBytes = NULL;
	}
	
	unsigned int width = (unsigned int)theSize.width;
	unsigned int height = (unsigned int)theSize.height;
	imageBytes = (char*)malloc( width * height * 4 );
	if( !imageBytes ) {
		printf("Could not allocate bytes for CGImage for drawable!\n");
		return NULL;
	}
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGB );
	CGContextRef bitmapContext = CGBitmapContextCreate( imageBytes, width, height, 8, width*4,colorSpace, kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease( colorSpace );
	
	if( bitmapContext == NULL ) {
		printf("Could not create bitmap context!\n");
		return NULL;
	}
	
	[self drawInRect:NSMakeRect(0.0f,0.0f,theSize.width,theSize.height) inContext:bitmapContext];
	
	image = CGBitmapContextCreateImage( bitmapContext );
	CGContextRelease( bitmapContext );
	
	if( image == NULL ) {
		printf("Could not create CGImage from bitmapContext for drawable!\n");
		return NULL;
	}
	
	cgImageSize = theSize;
	return image;
}

#pragma mark subclass should override

- (void)drawInRect:(NSRect)theRect inContext:(CGContextRef)theContext;
{
	CGContextSaveGState( theContext );
	
	CGContextSetRGBFillColor( theContext,0.0f,0.0f,0.0f,1.0f);
	CGContextFillRect( theContext, *(CGRect *)&theRect );
	
	CGContextRestoreGState( theContext );
}


@end

//
//  TriviaDrawable.h
//  TriviaPlayer
//
//  Created by Nur Monson on 10/7/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TriviaDrawable : NSObject {
	NSSize layerSize;
	NSSize cgImageSize;
	char *imageBytes;
	CGImageRef image;
	CGLayerRef layer;
}

- (id)init;

- (void)drawInRect:(NSRect)theRect inContext:(CGContextRef)theContext;
- (CGLayerRef)getLayer;
- (CGLayerRef)makeLayerForSize:(NSSize)theSize withContext:(CGContextRef)theContext;
- (CGImageRef)makeCGImageForSize:(NSSize)theSize;

@end

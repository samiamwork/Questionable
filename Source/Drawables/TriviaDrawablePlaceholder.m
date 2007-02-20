//
//  TriviaDrawablePlaceholder.m
//  TriviaPlayer
//
//  Created by Nur Monson on 10/7/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaDrawablePlaceholder.h"
#include "TIPCGUtils.h"

#define LINEWIDTH 5.0f
#define MARGIN 20.0f

@implementation TriviaDrawablePlaceholder

- (id)init
{
	if( (self = [super init]) ) {
		NSString *path = [[NSBundle mainBundle] pathForResource:@"triviaplaceholder" ofType:@"pdf"];
		CFURLRef url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)path, kCFURLPOSIXPathStyle, 0);
		
		if( !url )
			printf("could get URL!\n");
		
		bgImage = CGPDFDocumentCreateWithURL( url );
		if( !bgImage )
			printf("could not create pdf document!\n");
		
		CFRelease( url );
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	CGPDFDocumentRelease(bgImage);
}

- (void)drawInRect:(NSRect)theRect inContext:(CGContextRef)theContext
{
	CGContextSaveGState( theContext );

	CGContextSetRGBFillColor( theContext, 0.0f, 0.0f, 0.0f, 1.0f);
	CGContextFillRect( theContext, *(CGRect *)&theRect);
	
	CGPDFPageRef pageRef = CGPDFDocumentGetPage( bgImage,1 );
	CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform( pageRef, kCGPDFMediaBox, *(CGRect *)&theRect, 0, YES );

	CGContextConcatCTM( theContext, pdfTransform );
	CGContextDrawPDFPage( theContext, pageRef );

	CGContextRestoreGState( theContext );
}

@end
